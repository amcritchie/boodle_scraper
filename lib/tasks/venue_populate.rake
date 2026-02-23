namespace :venue do
  desc "Populate venues and mark the 32 true home venues"
  task populate: :environment do
    puts "🏟️  Starting venue population..."
    
    # Hash mapping venue slugs to team slugs for the 32 true NFL home venues (current stadiums as of 2024/2025)
    true_home_venues = {
      # AFC East
      "highmark-stadium" => ["buf"],                           # Buffalo Bills
      "hard-rock-stadium" => ["mia"],                       # Miami Dolphins  
      "gillette-stadium" => ["ne"],                         # New England Patriots
      "metlife-stadium" => ["nyj", "nyg"],                 # New York Jets & Giants (shared)
      
      # AFC North
      "m&t-bank-stadium" => ["bal"],                        # Baltimore Ravens
      "paycor-stadium" => ["cin"],                          # Cincinnati Bengals
    #   "firstenergy-stadium" => ["cle"],                     # Cleveland Browns
      "huntington-bank-field" => ["cle"],                     # Cleveland Browns
      "acrisure-stadium" => ["pit"],                        # Pittsburgh Steelers
      
      # AFC South
      "nrg-stadium" => ["hou"],                             # Houston Texans
      "lucas-oil-stadium" => ["ind"],                       # Indianapolis Colts
      "everbank-stadium" => ["jax"],                         # Jacksonville Jaguars
      "nissan-stadium" => ["ten"],                          # Tennessee Titans
      
      # AFC West
      "empower-field-at-mile-high" => ["den"],             # Denver Broncos
      "geha-field-at-arrowhead-stadium" => ["kc"],         # Kansas City Chiefs
      "sofi-stadium" => ["lac", "lar"],                    # Los Angeles Chargers & Rams (shared)
      "allegiant-stadium" => ["lv"],                        # Las Vegas Raiders
      
      # NFC East
      "at&t-stadium" => ["dal"],                            # Dallas Cowboys
      "lincoln-financial-field" => ["phi"],                # Philadelphia Eagles
      "northwest-stadium" => ["was"],                              # Washington Commanders (note: may change names)
      
      # NFC North
      "soldier-field" => ["chi"],                           # Chicago Bears
      "ford-field" => ["det"],                              # Detroit Lions
      "lambeau-field" => ["gb"],                            # Green Bay Packers
      "u.s.-bank-stadium" => ["min"],                       # Minnesota Vikings
      
      # NFC South
      "mercedes-benz-stadium" => ["atl"],                   # Atlanta Falcons
      "bank-of-america-stadium" => ["car"],                 # Carolina Panthers
      "caesars-superdome" => ["no"],                        # New Orleans Saints
      "raymond-james-stadium" => ["tb"],                    # Tampa Bay Buccaneers
      
      # NFC West
      "state-farm-stadium" => ["ari"],                      # Arizona Cardinals
      "levi's-stadium" => ["sf"],                           # San Francisco 49ers
      "lumen-field" => ["sea"]                              # Seattle Seahawks
    }
    
    true_home_venue_slugs = true_home_venues.keys
    
    puts "📋 Identified #{true_home_venue_slugs.length} unique home venue slugs"
    
    # First, reset all venues to not be true_home and clear team venue_slug fields
    Venue.update_all(true_home: false)
    Team.update_all(venue_slug: nil)
    puts "🔄 Reset all venues to not be true home and cleared team venue_slug fields"
    
    # Each through home venues 
    true_home_venues.each do |venue_slug, team_slugs|
      # Find or Create Venue
      venue = Venue.find_or_create_by(slug: venue_slug.venue_slugify)
      # Update that venue is a true home.
      venue.update(true_home: true)
      # Update team's venue slug to identify home games
      team_slugs.each do |team_slug|
        if team = Team.find_by(slug: team_slug)
          team.update!(venue_slug: venue_slug)
          puts "✅ #{team_slug.upcase.ljust(4)} -> #{venue_slug} (#{venue.name})"
        else
          puts "⚠️  Warning: Team '#{team_slug}' not found in database"
        end
      end
    end
    
    # Display the venues marked as true home with their teams
    puts "\n🏟️  True Home Venues & Teams:"
    Venue.where(true_home: true).order(:name).each do |venue|
      teams_at_venue = Team.where(venue_slug: venue.slug).pluck(:slug).map(&:upcase)
      teams_at_venue = Team.where(venue_slug: venue.slug).map{|team| "#{team.slug} #{team.emoji}".upcase}
      team_display = teams_at_venue.any? ? teams_at_venue.join(", ") : "No teams assigned"
      puts "   #{venue.slug.ljust(32)} | #{venue.name.ljust(32)} | #{team_display}"
    end
    
    puts "\n✅ Venue population completed!"
  end
  
  desc "List all venues with their true_home status and teams"
  task list: :environment do
    puts "🏟️  All Venues:"
    puts "   #{"Slug".ljust(35)} | #{"Name".ljust(30)} | True Home | Teams"
    puts "   #{"-" * 90}"
    
    Venue.order(:name).each do |venue|
      true_home_indicator = venue.true_home? ? "✅" : "❌"
      teams_at_venue = Team.where(venue_slug: venue.slug).pluck(:slug).map(&:upcase)
      team_display = teams_at_venue.any? ? teams_at_venue.join(", ") : "-"
      puts "   #{venue.slug.ljust(35)} | #{venue.name.ljust(30)} | #{true_home_indicator.ljust(9)} | #{team_display}"
    end
    
    puts "\n📊 Summary: #{Venue.where(true_home: true).count} true home venues out of #{Venue.count} total venues"
    puts "📊 Teams with venue_slug: #{Team.where.not(venue_slug: nil).count} out of #{Team.count} total teams"
  end
end
