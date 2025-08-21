namespace :betting do
  desc "Test betting data functionality for a specific week"
  task :test, [:season, :week] => :environment do |t, args|
    season = args[:season] || 2025
    week_sequence = args[:week] || 1
    
    puts "Testing betting data functionality for Week #{week_sequence} of #{season}"
    
    # Find the week
    week = Week.find_by(season_year: season, sequence: week_sequence)
    
    unless week
      puts "❌ Week #{week_sequence} of #{season} not found"
      exit 1
    end
    
    puts "✅ Found Week #{week.sequence} of #{week.season_year}"
    puts "Games in this week: #{week.all_games.count}"
    
    # Display current betting data
    puts "\n" + "="*50
    week.display_betting_data
    
    # Test validation
    puts "\n" + "="*50
    week.validate_betting_data
    
    puts "\n✅ Testing complete!"
  end
  
  desc "Display betting data for all weeks in a season"
  task :display_season, [:season] => :environment do |t, args|
    season = args[:season] || 2025
    
    puts "Displaying betting data for Season #{season}"
    puts "="*50
    
    weeks = Week.where(season_year: season).order(:sequence)
    
    if weeks.empty?
      puts "❌ No weeks found for season #{season}"
      exit 1
    end
    
    weeks.each do |week|
      puts "\nWeek #{week.sequence}"
      puts "-" * 20
      
      games_with_data = week.all_games.where.not(favorite: nil).count
      total_games = week.all_games.count
      
      puts "Games with betting data: #{games_with_data}/#{total_games}"
      
      if games_with_data > 0
        week.display_betting_data
      else
        puts "No betting data available"
      end
    end
    
    puts "\n✅ Season summary complete!"
  end
end
