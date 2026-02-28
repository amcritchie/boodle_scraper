class ArticleIngestionService
  require "net/http"
  require "json"
  require "digest"

  # Model options: claude-sonnet, minimax-m2.1, grok-3, gemini-flash
  DEFAULT_MODEL = "claude-sonnet"

  def self.ingest(url:, model: DEFAULT_MODEL)
    new(url: url, model: model).call
  end

  def initialize(url:, model: DEFAULT_MODEL)
    @url = url
    @model = model
    @extracted_data = nil
  end

  def call
    # 1. Fetch article content
    article_content = fetch_article(@url)

    # 2. Extract structured data using LLM (via sub-agent)
    @extracted_data = extract_with_llm(article_content)

    # 3. Map to Article schema
    article_attrs = map_to_article(@extracted_data, @url)

    # 4. Check for existing article with same source_url
    existing = Article.find_by(source_url: @url)
    if existing
      existing.update(article_attrs)
      return existing
    end

    # 5. Save new article
    article = Article.create!(article_attrs)
    article
  rescue => e
    Rails.logger.error "ArticleIngestionService error: #{e.message}"
    raise e
  end

  private

  def fetch_article(url)
    uri = URI(url)
    response = Net::HTTP.get_response(uri)
    raise "Failed to fetch article: #{response.code}" unless response.code == "200"
    response.body
  end

  def extract_with_llm(content)
    # Build extraction prompt matching Article schema
    prompt = build_extraction_prompt(content)

    # Call LLM via API - returns JSON matching Article fields exactly
    # This would integrate with the LLM API in production
    # For now, returns structured hash that maps to Article
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
      You are extracting structured data from a sports article for storage in a database.

      Return ONLY a valid JSON object with these EXACT fields (no other text):
      {
        "title_summary": "2-3 sentence summary of the article",
        "sport": "NFL, NBA, MLB, NCAAF, NCAAB, NHL, or other sport",
        "teams_json": ["list of team names mentioned"],
        "people_json": ["list of player/person names with relevant details"],
        "key_stats_json": ["list of important statistics with numbers"],
        "context": "1-2 sentence background/context about the article",
        "angles_json": ["list of storyline angles"]
      }

      Article content (first 8000 chars):
      #{content[0..8000]}
    PROMPT
  end

  def extract_summary(content)
    # Simple extraction - in production, this comes from LLM
    content[0..200].split("\n").first || "Summary extracted from article"
  end

  def extract_sport(content)
    sport_keywords = {
      "NFL" => ["nfl", "football", "quarterback", "touchdown", "yard dash"],
      "NBA" => ["nba", "basketball", "points", "rebounds", "assist"],
      "MLB" => ["mlb", "baseball", "home run", "innings", "pitcher"],
      "NCAAB" => ["college basketball", "ncaab", "big ten", "acc", "sec"],
      "NCAAF" => ["college football", "ncaaf", "draft", "combine"]
    }

    content_lower = content.downcase
    sport_keywords.each do |sport, keywords|
      return sport if keywords.any? { |k| content_lower.include?(k) }
    end
    "Sports"
  end

  def extract_teams(content)
    # Simple team extraction - in production, use NER or LLM
    teams = []
    # Common team patterns
    team_patterns = [
      /([A-Z][a-z]+(?: [A-Z][a-z]+)*) (?:vs\.?|beat|defeated|over)/,
      /([A-Z][a-z]+(?: [A-Z][a-z]+)*) (?:won|loss|record)/
    ]
    teams.uniq
  end

  def extract_people(content)
    people = []
    # Extract names - simple pattern matching
    content.scan(/([A-Z][a-z]+ [A-Z][a-z]+)/).flatten[0..20]
  end

  def extract_stats(content)
    stats = []
    # Extract numbers with context
    content.scan(/\d+(?:\.\d+)?%|\d+(?:\.\d+)? (?:yards|points|seconds|feet|inches)/).first(10)
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
