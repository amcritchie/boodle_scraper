class ArticleIngestionService
  require "net/http"
  require "json"
  require "digest"
  require "open-uri"

  MODELS = ["claude-sonnet", "minimax-m2.1", "grok-3"]
  DEFAULT_MODEL = "claude-sonnet"

  # API configuration - requires environment variables
  API_CONFIG = {
    "claude-sonnet" => {
      "base_url" => "https://api.anthropic.com/v1/messages",
      "api_key" => ENV["ANTHROPIC_API_KEY"],
      "model" => "claude-sonnet-4-20250514"
    },
    "minimax-m2.1" => {
      "base_url" => "https://api.minimax.chat/v1/text/chatcompletion_v2",
      "api_key" => ENV["MINIMAX_API_KEY"],
      "model" => "MiniMax-Text-01"
    },
    "grok-3" => {
      "base_url" => "https://api.x.ai/v1/chat/completions",
      "api_key" => ENV["XAI_API_KEY"],
      "model" => "grok-3"
    }
  }

  # Runs all 3 models sequentially - creates tasks for each
  def self.ingest(url:)
    MODELS.each do |model|
      task = Task.create!(
        task_type: "article_ingestion",
        status: "idle",
        input_json: { url: url, model: model }
      )
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
    @task = Task.find(@task_id)
    @task.update!(status: "active", started_at: Time.current)

    begin
      article_content = fetch_article(@url)
      @extracted_data = extract_with_llm(article_content)
      image_path = download_og_image(@url)

      article_attrs = map_to_article(@extracted_data, @url).merge(
        model: @model,
        image_options: image_path ? [image_path] : []
      )

      article = Article.create!(article_attrs)

      @task.update!(
        status: "completed",
        output_json: { article_id: article.id, image_path: image_path },
        completed_at: Time.current
      )

      article
    rescue => e
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
    
    # Call actual LLM API
    llm_response = call_llm_api(prompt)
    
    # Parse JSON response
    parse_llm_response(llm_response)
  rescue => e
    Rails.logger.error "LLM extraction failed: #{e.message}. Using fallback."
    # Fallback to stubbed extraction
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

  def call_llm_api(prompt)
    config = API_CONFIG[@model]
    raise "Unknown model: #{@model}" unless config

    uri = URI.parse(config["base_url"])
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    case @model
    when "claude-sonnet"
      request = Net::HTTP::Post.new(uri.path)
      request["x-api-key"] = config["api_key"]
      request["anthropic-version"] = "2023-06-01"
      request["Content-Type"] = "application/json"
      request.body = {
        model: config["model"],
        max_tokens: 1024,
        messages: [{ role: "user", content: prompt }]
      }.to_json

    when "minimax-m2.1"
      request = Net::HTTP::Post.new(uri.path)
      request["Authorization"] = "Bearer #{config["api_key"]}"
      request["Content-Type"] = "application/json"
      request.body = {
        model: config["model"],
        messages: [{ role: "user", content: prompt }]
      }.to_json

    when "grok-3"
      request = Net::HTTP::Post.new(uri.path)
      request["Authorization"] = "Bearer #{config["api_key"]}"
      request["Content-Type"] = "application/json"
      request.body = {
        model: config["model"],
        messages: [{ role: "user", content: prompt }]
      }.to_json
    end

    response = http.request(request)
    raise "LLM API error: #{response.code} - #{response.body}" unless response.code == "200"
    
    parse_model_response(response.body, @model)
  end

  def parse_model_response(body, model)
    data = JSON.parse(body)
    
    case model
    when "claude-sonnet"
      data.dig("content", 0, "text")
    when "minimax-m2.1"
      data.dig("choices", 0, "message", "content")
    when "grok-3"
      data.dig("choices", 0, "message", "content")
    end
  end

  def parse_llm_response(response_text)
    # Extract JSON from response
    json_match = response_text.match(/\{.*\}/m)
    return {} unless json_match

    JSON.parse(json_match[0])
  rescue JSON::ParserError
    {}
  end

  def build_extraction_prompt(content)
    <<~PROMPT
      You are extracting structured data from a sports article for storage in a database.
      Return ONLY a valid JSON object with these EXACT fields (no other text):
      {
        "title_summary": "2-3 sentence summary of the article",
        "sport": "NFL, NBA, MLB, Soccer, or other sport",
        "teams_json": ["list of team names mentioned"],
        "people_json": ["list of player/person names with relevant details"],
        "key_stats_json": ["list of important statistics with numbers"],
        "context": "1-2 sentence background/context about the article"
      }

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
      "Soccer" => ["soccer", "goal", "match", "champions cup"]
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

      filename = slugify(url) + "-og.jpg"
      filepath = Rails.root.join("uploads", filename)

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
