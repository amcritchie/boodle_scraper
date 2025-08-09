require 'csv'
require 'nokogiri'
require 'httparty'

namespace :scrape do
  desc "Scrape starting Left Tackles from PFF website and create CSV"
  task left_tackles: :environment do
    puts "Starting to scrape Left Tackles from PFF website..."
    
    base_url = ENV.fetch('PFF_BASE_URL', 'https://www.pff.com')
    url = "#{base_url}/news/nfl-projecting-all-32-nfl-starting-lineups-2025-season"
    
    begin
      response = HTTParty.get(url)
      
      if response.success?
        puts "Successfully fetched the webpage"
        
        doc = Nokogiri::HTML(response.body)
        
        # Initialize array to store left tackle data
        left_tackles = []
        
        # Look for team sections and extract left tackle information
        # The structure might vary, so we'll try different selectors
        team_sections = doc.css('h2, h3, h4').select { |h| h.text.match?(/team|offense|line/i) }
        
        puts "Found #{team_sections.length} potential team sections"
        
        # Alternative approach: look for specific patterns in the text
        content_text = doc.text
        
        # Split by teams and look for left tackle mentions
        teams = [
          'Arizona Cardinals', 'Atlanta Falcons', 'Baltimore Ravens', 'Buffalo Bills',
          'Carolina Panthers', 'Chicago Bears', 'Cincinnati Bengals', 'Cleveland Browns',
          'Dallas Cowboys', 'Denver Broncos', 'Detroit Lions', 'Green Bay Packers',
          'Houston Texans', 'Indianapolis Colts', 'Jacksonville Jaguars', 'Kansas City Chiefs',
          'Las Vegas Raiders', 'Los Angeles Chargers', 'Los Angeles Rams', 'Miami Dolphins',
          'Minnesota Vikings', 'New England Patriots', 'New Orleans Saints', 'New York Giants',
          'New York Jets', 'Philadelphia Eagles', 'Pittsburgh Steelers', 'San Francisco 49ers',
          'Seattle Seahawks', 'Tampa Bay Buccaneers', 'Tennessee Titans', 'Washington Commanders'
        ]
        
        teams.each do |team|
          # Look for left tackle information near team name
          team_pattern = /#{Regexp.escape(team)}.*?(?:left tackle|lt|left t).*?([A-Z][a-z]+ [A-Z][a-z]+)/i
          match = content_text.match(team_pattern)
          
          if match
            left_tackle_name = match[1]
            left_tackles << {
              team: team,
              left_tackle: left_tackle_name,
              source: url
            }
            puts "Found: #{team} - #{left_tackle_name}"
          else
            puts "Could not find left tackle for #{team}"
            left_tackles << {
              team: team,
              left_tackle: "Not found",
              source: url
            }
          end
        end
        
        # Create CSV file
        csv_file_path = Rails.root.join('lib', 'assets', 'left_tackles_2025.csv')
        
        CSV.open(csv_file_path, 'w') do |csv|
          csv << ['Team', 'Left Tackle', 'Source']
          left_tackles.each do |lt|
            csv << [lt[:team], lt[:left_tackle], lt[:source]]
          end
        end
        
        puts "CSV file created at: #{csv_file_path}"
        puts "Total left tackles found: #{left_tackles.count { |lt| lt[:left_tackle] != 'Not found' }}"
        
      else
        puts "Failed to fetch webpage. Status code: #{response.code}"
      end
      
    rescue => e
      puts "Error occurred: #{e.message}"
      puts e.backtrace.first(5)
    end
  end
end 