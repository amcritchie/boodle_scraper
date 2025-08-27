namespace :rankings do
  desc "Populate offensive line rankings for Week 1 2025"
  task populate_oline_rankings: :environment do
    puts "Starting offensive line rankings population..."
    
    ranking_slug = "2025_week_1_olinemen_rank"
    week = 1
    season = 2025
    
    # Clear existing rankings for this slug
    Ranking.where(ranking_slug: ranking_slug).destroy_all
    puts "Cleared existing rankings for #{ranking_slug}"
    
    # Find the relevant week record and get teams_weeks
    week_record = Week.find_by(season_year: season, sequence: week)
    
    if week_record.nil?
      puts "No week record found for Week #{week} #{season}. Exiting."
      return
    end
    
    teams_weeks = TeamsWeek.where(season_year: season, week_number: week)
    
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
    
    # Get all players with their grades
    player_slugs = oline_data.map(&:first)
    players = Player.where(slug: player_slugs)
                    .where.not(grades_pass_block: [nil, 0])
                    .includes(:team)
    
    puts "Processing #{players.count} players with valid grades..."
    
    # Calculate rankings for each category
    offense_rankings = players.order(grades_offense: :desc).map.with_index { |p, i| [p.slug, i + 1] }.to_h
    pass_block_rankings = players.order(grades_pass_block: :desc).map.with_index { |p, i| [p.slug, i + 1] }.to_h
    run_block_rankings = players.order(grades_run_block: :desc).map.with_index { |p, i| [p.slug, i + 1] }.to_h
    
    # Create ranking records
    rankings_created = 0
    players.each do |player|
      # Find the position for this player
      position_data = oline_data.find { |slug, _| slug == player.slug }
      position = position_data ? position_data.last : 'Unknown'
      
      ranking = Ranking.create!(
        ranking_slug: ranking_slug,
        week: week,
        player_slug: player.slug,
        position: position,
        rank_1: offense_rankings[player.slug] || 999,
        rank_2: pass_block_rankings[player.slug] || 999,
        rank_3: run_block_rankings[player.slug] || 999
      )
      
      if ranking.persisted?
        rankings_created += 1
        puts "Created ranking for #{player.first_name} #{player.last_name} (#{player.team_slug}) - #{position}"
      end
    end
    
    puts "Successfully created #{rankings_created} ranking records"
    puts "Ranking slug: #{ranking_slug}"
    puts "Week: #{week}"
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
