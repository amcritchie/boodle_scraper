namespace :rankings do
  desc "Populate offensive line rankings for Week 1 2025"
  task populate_oline_rankings: :environment do
    puts "Starting offensive line rankings population..."
    
    ranking_slug = "2025_week_1_olinemen_rank"
    week_number = 1
    season = 2025

    week = Week.find_by(season_year: 2025, sequence: week_number)
    ranking_slug = "olinemen_rank"
    ranking_slug_detail = "#{season}_week_#{week_number}_#{ranking_slug}"

    # Clear existing rankings for this slug
    Ranking.where(ranking_slug: ranking_slug).destroy_all
    puts "Cleared existing rankings for #{ranking_slug}"
    
    # Find the relevant week record and get teams_weeks
    # week_record = Week.find_by(season_year: season, sequence: week)    
    if week.nil?
      puts "No week record found for Week #{week} #{season}. Exiting."
      return
    end
    
    teams_weeks = week.teams_weeks
    
    if teams_weeks.empty?
      puts "No teams_weeks found for Week #{week} #{season}. Exiting."
      return
    end
    
    # Extract offensive line player slugs with their positions
    oline_data = []
    teams_weeks.each do |tw|
      oline_data << [tw.c, 'C'] if tw.c
      oline_data << [tw.lt, 'LT'] if tw.lt
      oline_data << [tw.rt, 'RT'] if tw.rt
      oline_data << [tw.lg, 'LG'] if tw.lg
      oline_data << [tw.rg, 'RG'] if tw.rg
    end
    
    # Remove duplicates while preserving position information
    oline_data = oline_data.uniq { |slug, _| slug }
    
    puts "Found #{oline_data.count} offensive line players"
    
    # Get all players (including those without grades to rank all 160 starters)
    player_slugs = oline_data.map(&:first)
    players = Player.where(slug: player_slugs)
                    .includes(:team)
    
    puts "Processing #{players.count} players (including all starters)..."
    
    # Calculate rankings for each category using dynamic grade methods
    # Sort players by grade (using grade_x methods for dynamic fallbacks)
    offense_sorted = players.sort_by { |p| -p.grades_offense_x }
    pass_block_sorted = players.sort_by { |p| -p.pass_block_grade_x }
    run_block_sorted = players.sort_by { |p| -p.pass_rush_grade_x }
    
    # Create ranking hashes
    offense_rankings = offense_sorted.map.with_index { |p, i| [p.slug, i + 1] }.to_h
    pass_block_rankings = pass_block_sorted.map.with_index { |p, i| [p.slug, i + 1] }.to_h
    run_block_rankings = run_block_sorted.map.with_index { |p, i| [p.slug, i + 1] }.to_h
    
    # Create ranking records
    rankings_created = 0
    players.each do |player|
      # Find the position for this player
      position_data = oline_data.find { |slug, _| slug == player.slug }
      position = position_data ? position_data.last : 'Unknown'

      ranking = Ranking.find_or_create_by(
        ranking_slug: ranking_slug,
        ranking_slug_detail: ranking_slug_detail,
        week: week.sequence,
        season: season,
        player_slug: player.slug
      )
      # Update rank and position
      ranking.update(
        position: position,
        rank_1: offense_rankings[player.slug] || 999,
        rank_2: pass_block_rankings[player.slug] || 999,
        rank_3: run_block_rankings[player.slug] || 999,
        sample_size: players.count
      )
      
      if ranking.persisted?
        rankings_created += 1
        puts "Created ranking for #{player.first_name} #{player.last_name} (#{player.team_slug}) - #{position}"
      end
    end
    
    puts "Successfully created #{rankings_created} ranking records"
    puts "Ranking slug: #{ranking_slug}"
    puts "Week: #{week.sequence}"
    puts "Season: #{season}"
    
    # Display some sample rankings
    puts "\nSample Rankings (Top 5 Pass Block):"
    Ranking.where(ranking_slug: ranking_slug)
           .order(:rank_2)
           .limit(5)
           .includes(:player)
           .each do |ranking|
      player = ranking.player
      puts "  #{ranking.rank_2}. #{player&.first_name} #{player&.last_name} (#{player&.team_slug}) - #{ranking.position} - Pass Block Rank: #{ranking.rank_2}"
    end
  end
end
