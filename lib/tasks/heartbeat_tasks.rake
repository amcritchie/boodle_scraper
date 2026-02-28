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
      
      case task.task_type
      when "article_ingestion"
        url = task.input_json["url"]
        model = task.input_json["model"] || "claude-sonnet"
        
        begin
          task.update!(
            status: "active", 
            started_at: Time.current,
            execute_count: task.execute_count + 1
          )
          
          # Use the service - it handles task lifecycle
          ArticleIngestionService.new(url: url, model: model, task_id: task.id).call
          
          puts "Task ##{task.id} completed successfully"
        rescue => e
          task.add_error(e.message)
          task.update!(
            status: "failed", 
            error: e.message, 
            completed_at: Time.current
          )
          puts "Task ##{task.id} failed: #{e.message}"
        end
      else
        puts "Unknown task type: #{task.task_type}"
      end
    end
    
    puts "Done processing idle tasks."
  end
  
  desc "Run all heartbeat checks"
  task heartbeat: [:check_stuck, :process_idle]
end
