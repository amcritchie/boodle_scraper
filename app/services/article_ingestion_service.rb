class ArticleIngestionService
  require "net/http"
  require "json"
  require "digest"
  require "open-uri"

  MODELS = ["claude-sonnet", "minimax-m2.1", "grok-3"]
  DEFAULT_MODEL = "claude-sonnet"

  # Runs all 3 models sequentially - creates tasks for each
  def self.ingest(url:)
    MODELS.each do |model|
      # Create task in idle state, worker picks it up
      task = Task.create!(
        task_type: "article_ingestion",
        status: "idle",
        input_json: { url: url, model: model }
      )
      
      # Process immediately (in production, a worker would pick this up)
      new(url: url, model: model, task_id: task.id).call
    end
  end

  # Runs single model - creates single task
  def self.ingest_single(url:, model: DEFAULT_MODEL)
    task = Task.create!(
      task_type: "article_ingestion",
      status: "idle",
      input_json: { url: url, model: model }
    )
    
    new(url: url, model: model, task_id: task.id).call
  end

  def initialize(url:, model: DEFAULT_MODEL, task_id: nil)
    @url = url
    @model = model
    @task_id = task_id
    @extracted_data = nil
  end

  def call
    # Mark task as active
    @task = Task.find(@task_id)
    @task.update!(status: "active", started_at: Time.current)

    begin
      # 1. Fetch article content
      article_content = fetch_article(@url)

      # 2. Extract structured data using LLM
      @extracted_data = extract_with_llm(article_content)

      # 3. Download og:image
      image_path = download_og_image(@url)

      # 4. Map to Article schema
      article_attrs = map_to_article(@extracted_data, @url).merge(
        model: @model,
        image_options: image_path ? [image_path] : []
      )

      # 5. Save new article
      article = Article.create!(article_attrs)

      # Update task as completed
      @task.update!(
        status: "completed",
        output_json: { article_id: article.id, image_path: image_path },
        completed_at: Time.current
      )

      article
    rescue => e
      # Update task as failed
      @task.update!(
        status: "failed",
        error: e.message,
        completed_at: Time.current
      )
      raise e
    end
  end

  private

  def fetch_article(url)
    uri = URI(url)
    response = Net::HTTP.get_response(uri)
    raise "Failed to fetch article: #{response.code}" unless response.code == "200"
    response.body
  end

  def extract_with_llm(content)
    prompt = build_extraction_prompt(content)

    # Stubbed - returns simple patterns instead of calling LLM
    {
      "title_summary" => extract_summary(content),
      "sport" => extract_sport(content),
      "teams_json" => extract_teams(content),
      "people_json" => extract_people(content),
      "key_stats_json" => extract_stats(content),
      "context" => extract_context(content),
      "source" => extract_source(@url),
      "source_url" => @url,
      "source_id" => generate_source_id(@url)
    }
  end

  def build_extraction_prompt(content)
    <<~PROMPT
      You are extracting structured data from a sports article.
      Return ONLY valid JSON with these fields:
      {"title_summary": "...", "sport": "...", "teams_json": [], "people_json": [], "key_stats_json": [], "context": "...", "angles_json": []}
      Article content (first 8000 chars):
      #{content[0..8000]}
    PROMPT
  end

  def extract_summary(content)
    content[0..200].split("\n").first || "Summary"
  end

  def extract_sport(content)
    sport_keywords = {
      "NFL" => ["nfl", "football", "quarterback", "touchdown"],
      "NBA" => ["nba", "basketball", "points", "rebounds"],
      "MLB" => ["mlb", "baseball", "home run", "pitcher"],
    }
    content_lower = content.downcase
    sport_keywords.each { |sport, keywords| return sport if keywords.any? { |k| content_lower.include?(k) } }
    "Sports"
  end

  def extract_teams(content)
    []
  end

  def extract_people(content)
    content.scan(/([A-Z][a-z]+ [A-Z][a-z]+)/).flatten[0..20]
  end

  def extract_stats(content)
    content.scan(/\d+(?:\.\d+)?%|\d+(?:\.\d+)? (?:yards|points|seconds)/).first(10)
  end

  def extract_context(content)
    "Article from #{extract_source(@url)}"
  end

  def extract_source(url)
    URI.parse(url).host&.gsub("www.", "") || "unknown"
  end

  def generate_source_id(url)
    Digest::SHA256.hexdigest(url)[0..16]
  end

  def download_og_image(url)
    begin
      html = fetch_article(url)
      og_image = html[/<meta property="og:image" content="([^"]*)"/, 1]
      return nil unless og_image

      # Generate filename from URL
      filename = slugify(url) + "-og.jpg"
      filepath = Rails.root.join("uploads", filename)

      # Download image
      File.open(filepath, "wb") do |file|
        URI.open(og_image) { |io| file.write(io.read) }
      end

      filepath.to_s
    rescue => e
      Rails.logger.error "Failed to download og:image: #{e.message}"
      nil
    end
  end

  def slugify(url)
    url.gsub(/https?:\/\//, "")
       .gsub(/[^a-z0-9]/, "-")
       .gsub(/-+/, "-")
       .chomp("-")[0..50]
  end

  def map_to_article(data, url)
    {
      title_summary: data["title_summary"],
      sport: data["sport"],
      teams_json: data["teams_json"],
      people_json: data["people_json"],
      key_stats_json: data["key_stats_json"],
      context: data["context"],
      source: extract_source(url),
      source_url: url,
      source_id: generate_source_id(url)
    }
  end
end
