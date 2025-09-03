namespace :rankings do
  desc "Populate quarterback rankings for Week 1 2025"
  task populate_qb_rankings: :environment do
    puts "Starting quarterback rankings population..."
    
    ranking_slug = "2025_week_1_quarterback_rank"
    week_number = 1
    season = 2025

    week = Week.find_by(season_year: 2025, sequence: week_number)
    ranking_slug = "quarterback_rank"
    ranking_slug_detail = "#{season}_week_#{week_number}_#{ranking_slug}"

    # Clear existing rankings for this slug
    Ranking.where(ranking_slug: ranking_slug).destroy_all
    puts "Cleared existing rankings for #{ranking_slug}"
    
    # Find the relevant week record and get teams_weeks
    if week.nil?
      puts "No week record found for Week #{week_number} #{season}. Exiting."
      return
    end
    
    teams_weeks = week.teams_weeks
    
    if teams_weeks.empty?
      puts "No teams_weeks found for Week #{week_number} #{season}. Exiting."
      return
    end
    
    # Extract quarterback player slugs
    qb_data = []
    teams_weeks.each do |tw|
      qb_data << [tw.qb, 'QB'] if tw.qb
    end
    
    # Remove duplicates while preserving position information
    qb_data = qb_data.uniq { |slug, _| slug }
    
    puts "Found #{qb_data.count} quarterback players"
    
    # Get all players (including those without grades to rank all 32 starters)
    player_slugs = qb_data.map(&:first)
    players = Player.where(slug: player_slugs)
                    .includes(:team)
    
    puts "Processing #{players.count} players (including all starters)..."
    
    # Predefined quarterback rankings for Week 1 2025
    w1_qb_rankings = [
        "quarterback-josh-allen",
        "quarterback-patrick-mahomes",
        "quarterback-lamar-jackson",
        "quarterback-joe-burrow",
        "quarterback-jalen-hurts",
        "quarterback-jayden-daniels",    
        "quarterback-justin-herbert",    
        "quarterback-baker-mayfield",
        "quarterback-geno-smith",
        "quarterback-bo-nix",
        "quarterback-jared-goff",
        "quarterback-kyler-murray",
        "quarterback-dak-prescott",
        "quarterback-cj-stroud",
        "quarterback-michael-penix",
        "quarterback-drake-maye",
        "quarterback-jordan-love",
        "quarterback-brock-purdy",
        "quarterback-matthew-stafford",
        "quarterback-aaron-rodgers",
        "quarterback-trevor-lawrence",
        "quarterback-caleb-williams",
        "quarterback-bryce-young",
        "quarterback-jj-mccarthy",  
        "quarterback-sam-darnold",
        "quarterback-justin-fields",
        "quarterback-tua-tagovailoa",
        "quarterback-russell-wilson",
        "quarterback-cam-ward",
        "quarterback-joe-flacco",
        "quarterback-daniel-jones",
        "quarterback-spencer-rattler",
    ]
    
    # Calculate separate passing and rushing rankings based on grades
    # Get all players from the predefined list
    predefined_players = Player.where(slug: w1_qb_rankings).includes(:team)
    
    # Sort by passing grades for rank_2 (passing)
    passing_sorted = predefined_players.sort_by { |p| -(p.grades_pass || 0) }
    passing_rankings = passing_sorted.map.with_index { |p, i| [p.slug, i + 1] }.to_h
    
    # Sort by rushing grades for rank_3 (rushing)  
    rushing_sorted = predefined_players.sort_by { |p| -(p.grades_run || 0) }
    rushing_rankings = rushing_sorted.map.with_index { |p, i| [p.slug, i + 1] }.to_h
    
    # Create ranking records using predefined order for overall, calculated for passing/rushing
    rankings_created = 0
    w1_qb_rankings.each_with_index do |qb_slug, index|
      player = Player.find_by(slug: qb_slug)
      next unless player
      
      overall_rank = index + 1  # Your predefined order
      passing_rank = passing_rankings[player.slug] || 999
      rushing_rank = rushing_rankings[player.slug] || 999
      position = 'QB'

      ranking = Ranking.find_or_create_by(
        ranking_slug: ranking_slug,
        ranking_slug_detail: ranking_slug_detail,
        week: week.sequence,
        season: season,
        player_slug: player.slug
      )
      # Update ranks: overall from your list, passing/rushing from grades
      ranking.update(
        position: position,
        rank_1: overall_rank,      # Your predefined overall ranking
        rank_2: passing_rank,      # Calculated from passing grades
        rank_3: rushing_rank,      # Calculated from rushing grades
        sample_size: w1_qb_rankings.length
      )
      
      if ranking.persisted?
        rankings_created += 1
        puts "Created ranking for #{player.first_name} #{player.last_name} (#{player.team_slug}) - Overall: #{overall_rank}, Passing: #{passing_rank}, Rushing: #{rushing_rank}"
      end
    end
    
    puts "Successfully created #{rankings_created} ranking records"
    puts "Ranking slug: #{ranking_slug}"
    puts "Week: #{week.sequence}"
    puts "Season: #{season}"
    
    # Display the predefined rankings
    puts "\nPredefined Quarterback Rankings (Top 10):"
    w1_qb_rankings.first(10).each_with_index do |qb_slug, index|
      player = Player.find_by(slug: qb_slug)
      if player
        puts "  #{index + 1}. #{player.first_name} #{player.last_name} (#{player.team_slug})"
      else
        puts "  #{index + 1}. #{qb_slug} (Player not found)"
      end
    end
    
    puts "\nSample Rankings from Database:"
    puts "\nTop 5 Overall (Your Predefined Order):"
    Ranking.where(ranking_slug: ranking_slug)
           .order(:rank_1)
           .limit(5)
           .includes(:player)
           .each do |ranking|
      player = ranking.player
      puts "  #{ranking.rank_1}. #{player&.first_name} #{player&.last_name} (#{player&.team_slug}) - Overall: #{ranking.rank_1}, Passing: #{ranking.rank_2}, Rushing: #{ranking.rank_3}"
    end
    
    puts "\nTop 5 Passing (By Grades):"
    Ranking.where(ranking_slug: ranking_slug)
           .order(:rank_2)
           .limit(5)
           .includes(:player)
           .each do |ranking|
      player = ranking.player
      puts "  #{ranking.rank_2}. #{player&.first_name} #{player&.last_name} (#{player&.team_slug}) - Overall: #{ranking.rank_1}, Passing: #{ranking.rank_2}, Rushing: #{ranking.rank_3}"
    end
    
    puts "\nTop 5 Rushing (By Grades):"
    Ranking.where(ranking_slug: ranking_slug)
           .order(:rank_3)
           .limit(5)
           .includes(:player)
           .each do |ranking|
      player = ranking.player
      puts "  #{ranking.rank_3}. #{player&.first_name} #{player&.last_name} (#{player&.team_slug}) - Overall: #{ranking.rank_1}, Passing: #{ranking.rank_2}, Rushing: #{ranking.rank_3}"
    end
  end
end
