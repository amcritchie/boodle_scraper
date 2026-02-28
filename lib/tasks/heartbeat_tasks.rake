namespace :tasks do
  desc "Check for stuck active tasks and restart them"
  task check_stuck: :environment do
    puts "Checking for stuck tasks..."
    
    Task.where(status: "active").each do |task|
      if task.stuck?
        puts "Task ##{task.id} is stuck (active for #{(Time.current - task.started_at).round}s). Restarting..."
        
        task.update!(
          status: "idle",
          error: "Stuck task restarted by heartbeat",
          started_at: nil,
          completed_at: nil,
          execute_count: task.execute_count + 1
        )
      end
    end
    
    puts "Done checking stuck tasks."
  end

  desc "Process all idle tasks"
  task process_idle: :environment do
    puts "Processing idle tasks..."
    
    Task.where(status: "idle").each do |task|
      unless task.can_retry?
        puts "Task ##{task.id} exceeded max retries (#{Task::MAX_RETRIES}). Skipping."
        task.update!(status: "failed", error: "Max retries exceeded")
        next
      end
      
      puts "Processing task ##{task.id} (attempt #{task.execute_count + 1})..."
      task.update!(status: "active", started_at: Time.current, execute_count: task.execute_count + 1)
      
      begin
        case task.task_type
        when "article_ingestion"
          url = task.input_json["url"]
          model = task.input_json["model"] || "claude-sonnet"
          ArticleIngestionService.new(url: url, model: model, task_id: task.id).call
          puts "Task ##{task.id} completed successfully"
          
        when "image_download"
          article_id = task.input_json["article_id"]
          url = task.input_json["url"]
          
          # Fetch URL and get og:image
          html = Net::HTTP.get(URI(url))
          og_image = html[/<meta property="og:image" content="([^"]*)"/, 1]
          
          if og_image
            # Generate filename
            article = Article.find(article_id)
            slug = article.main_person_name&.gsub(/[^a-z0-9]/i, "-")&.downcase || "article"
            filename = "#{slug}-#{article_id}.jpg"
            filepath = Rails.root.join("uploads", filename)
            
            # Download
            File.open(filepath, "wb") do |file|
              URI.open(og_image) { |io| file.write(io.read) }
            end
            
            # Update article - save to both image_selected and image_options (array)
            current_options = article.image_options || []
            article.update!(
              image_options: current_options + [filepath.to_s],
              image_selected: filepath.to_s
            )
            
            task.update!(
              status: "completed",
              output_json: { "saved_path" => filepath.to_s },
              completed_at: Time.current
            )
            puts "Task ##{task.id} completed - downloaded #{filepath}"
          else
            task.update!(status: "failed", error: "No og:image found", completed_at: Time.current)
          end
          
        else
          puts "Unknown task type: #{task.task_type}"
          task.update!(status: "failed", error: "Unknown task type", completed_at: Time.current)
        end
      rescue => e
        task.add_error(e.message)
        task.update!(status: "failed", error: e.message, completed_at: Time.current)
        puts "Task ##{task.id} failed: #{e.message}"
      end
    end
    
    puts "Done processing idle tasks."
  end
  
  desc "Run all heartbeat checks"
  task heartbeat: [:check_stuck, :process_idle]
end
