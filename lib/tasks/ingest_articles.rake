# Article Ingestion via LLM
# Usage: rails articles:ingest URL="https://..." MODEL="claude-sonnet"

namespace :articles do
  desc "Ingest an article from URL using LLM extraction"
  task :ingest, [:url, :model] => :environment do |_, args|
    url = args[:url] || ENV["URL"]
    model = args[:model] || ENV["MODEL"] || "claude-sonnet"

    raise "Usage: rails articles:ingest[URL] or URL=https://... rails articles:ingest" unless url

    puts "=" * 60
    puts "Article Ingestion"
    puts "=" * 60
    puts "URL: #{url}"
    puts "Model: #{model}"
    puts

    # For now, this is a placeholder - the actual extraction
    # would integrate with the sub-agent system
    puts "NOTE: Full LLM integration requires API access."
    puts "This would spawn a sub-agent to extract the article."
    puts
    puts "To use manually:"
    puts "1. Fetch article: web_fetch url='#{url}'"
    puts "2. Extract with LLM sub-agent"
    puts "3. POST to /api/articles with extracted data"
    puts "=" * 60
  end
end
