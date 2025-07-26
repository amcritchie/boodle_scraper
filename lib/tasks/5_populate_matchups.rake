namespace :matchups do

  desc "Populate matchups for Week 1, Season 2025"
  task populate_matchups: :environment do
    Team.active.each do |home_team|
      Team.active.each do |away_team|
        next if home_team == away_team
        Matchup.create!(
          season: 2025,
          week: 1,
          game: "#{home_team.name} vs #{away_team.name}",
          home_team: home_team.name,
          away_team: away_team.name,
          # Add logic to populate offensive and defensive lineups
          home_o1: "Player 1", away_d1: "Player A"
          # ...populate other positions...
        )
      end
    end
  end

  desc "Populate matchups for Week 1, Season 2025"
  task populate_2025_week_1: :environment do
    # First pass: Generate matchups and populate existing rankings
    Season.s2025.weeks.first.games.each do |game|
      # Generate matchups
      game.away_matchup
      game.home_matchup
    end

    # Second pass: Calculate attack rankings based on existing matchup scores
    puts "Calculating attack rankings based on matchup scores..."
    
    # Get all matchups for ranking
    all_matchups = Matchup.where(season: 2025, week_slug: 1)

    # all_matchups.order(passing_matchup_score: :desc).each do |matchup|
    #   puts "================"
    #   puts matchup.game
    #   puts matchup.team_slug
    #   puts "================"
    # end

    # all_matchups.order(passing_attack_rank: :desc)
    
    # weeks_matchups = []
    # all_matchups.each do |matchup|
    #   weeks_matchups << {
    #     matchup: matchup,
    #     passing_attack_rank: matchup.passing_attack_rank || 0,
    #     rushing_attack_rank: matchup.rushing_attack_rank || 0,
    #     field_goal_rank: matchup.field_goal_rank || 0
    #   }
    # end

    expected_passing_touchdowns = Matchup.passing_tds(32)
    expected_rushing_touchdowns = Matchup.rushing_tds(32)
    expected_field_goals = Matchup.field_goals(32)
    

    # Sort and assign ranks
    # weeks_matchups.sort_by! { |item| -item[:passing_attack_rank] }
    # Update matchups with ranks and calculate passing TDs
    all_matchups.order(passing_attack_score: :desc).each_with_index do |matchup, index|
      passing_td_points = 7 * expected_passing_touchdowns[index]
      matchup.update(
        passing_attack_rank: index + 1,
        passing_td_points: passing_td_points
      )
    end
    all_matchups.order(rushing_attack_score: :desc).each_with_index do |matchup, index|
      rushing_td_points = 7 * expected_rushing_touchdowns[index]
      matchup.update(
        rushing_attack_rank: index + 1,
        rushing_td_points: rushing_td_points
      )
    end
    all_matchups.order(field_goal_score: :desc).each_with_index do |matchup, index|
      field_goal_points = 3 * expected_field_goals[index]
      matchup.update(
        field_goal_rank: index + 1,
        field_goal_points: field_goal_points
      )
    end

    # # Sort and assign ranks
    # weeks_matchups.sort_by! { |item| -item[:passing_attack_rank] }
    # # Update matchups with ranks and calculate passing TDs
    # weeks_matchups.each_with_index do |item, index|
    #   item[:matchup].update(
    #     passing_attack_rank: index + 1,
    #     passing_touchdowns: expected_passing_touchdowns[index]
    #   )
    # end

    # # Sort and assign ranks
    # weeks_matchups.sort_by! { |item| -item[:rushing_attack_rank] }
    # # Update matchups with ranks and calculate rushing TDs
    # weeks_matchups.each_with_index do |item, index|
    #   rank = index + 1
    #   rushing_tds = item[:matchup].rushing_tds[rank - 1] || 0
      
    #   item[:matchup].update(
    #     rushing_attack_rank: rank,
    #     rushing_touchdowns: rushing_tds
    #   )
    # end

    # # Sort and assign ranks
    # weeks_matchups.sort_by! { |item| -item[:field_goal_rank] }
    # # Update matchups with ranks and calculate field goals
    # weeks_matchups.each_with_index do |item, index|
    #   rank = index + 1
    #   field_goals = item[:matchup].field_goals[rank - 1] || 0
      
    #   item[:matchup].update(
    #     field_goal_rank: rank,
    #     field_goals: field_goals
    #   )
    # end



    # rushing_attack_scores.sort_by! { |item| -item[:score] }


    # # Calculate passing attack scores for all matchups
    # passing_attack_scores = []
    # all_matchups.each do |matchup|
    #   passing_attack_scores << {
    #     matchup: matchup,
    #     score: matchup.passing_attack_score || 0
    #   }
    # end
    
    # # Calculate rushing attack scores for all matchups
    # rushing_attack_scores = []
    # all_matchups.each do |matchup|
    #   rushing_attack_scores << {
    #     matchup: matchup,
    #     score: matchup.rushing_attack_score || 0
    #   }
    # end
    
    # # Sort and assign ranks
    # passing_attack_scores.sort_by! { |item| -item[:score] }
    # rushing_attack_scores.sort_by! { |item| -item[:score] }
    
    # # Update matchups with ranks
    # passing_attack_scores.each_with_index do |item, index|
    #   item[:matchup].update(passing_attack_rank: index + 1)
    # end
    
    # rushing_attack_scores.each_with_index do |item, index|
    #   item[:matchup].update(rushing_attack_rank: index + 1)
    # end
    
    # # Calculate and assign field goal attack ranks using Coach class method
    # field_goal_attack_scores = Coach.assign_field_goal_ranks(all_matchups, 2025)

    puts "Attack ranking populated successfully!"
    # puts "Passing attack rankings calculated for #{passing_attack_scores.count} matchups"
    # puts "Rushing attack rankings calculated for #{rushing_attack_scores.count} matchups"
    # puts "Field goal attack rankings calculated for #{field_goal_attack_scores.count} matchups"
  end

  desc "Populate matchups for Week 1, Season 2025 Buffalo Bills"
  task populate: :environment do
    # Each through active teams
    Team.active.each do |team|
        # Generate Week 1 Roster
        team.generate_matchup(1,2024)
    end
  end

  desc "Populate matchups for Seasons 2024-2020"
  task populate_2024_2020: :environment do

    seasons         = [2020,2021,2022,2023,2024]
    $score_summary  = ["season,week,team,passingTDs,rushingTDs,fieldGoals,extraPoints,altPoints"]
    $week_summary   = ["season,week,passingGames,rushingGames,fgGames,+4passingTDs,3passingTDs,2passingTDs,1passingTD,0passingTDs,+4rushingTDs,3rushingTDs,2rushingTDs,1rushingTDs,0rushingTDs,5fieldGoals,4fieldGoals,3fieldGoals,2fieldGoals,1fieldGoals,0fieldGoals"]
    
    # Get collection of weeks
    weeks = Week.where(season_year: seasons).where.not(sportsradar_id: nil).order(sequence: :desc)
    # Each through weeks collection
    weeks.each do |week|

      # Each trough games and populate
      week.sport_radar_week

      # Get summary data using the helper method
      summary = week.scoring_categories_summary

      $week_summary.push("#{week.season_year},#{week.sequence},#{summary[:passing_games]},#{summary[:rushing_games]},#{summary[:fg_games]},#{week.passing_tds_4},#{week.passing_tds_3},#{week.passing_tds_2},#{week.passing_tds_1},#{week.passing_tds_0},#{week.rushing_tds_4},#{week.rushing_tds_3},#{week.rushing_tds_2},#{week.rushing_tds_1},#{week.rushing_tds_0},#{week.field_goals_5},#{week.field_goals_4},#{week.field_goals_3},#{week.field_goals_2},#{week.field_goals_1},#{week.field_goals_0}")
    end

    # puts summary
    weeks.scoring_summary_puts

    puts $score_summary
    puts $week_summary
  end

  desc "Populate matchups for Season 2024"
  task populate_2024: :environment do
    
    seasons = [2024]
    # Get collection of weeks
    weeks = Week.where(season_year: seasons).where.not(sportsradar_id: nil).order(sequence: :desc)
    # Week.where(season_year: 2024, sequence: 2).where.not(sportsradar_id: nil).order(sequence: :asc).limit(1).each do |week|
    weeks.each do |week|
      # Each trough games and populate
      week.sport_radar_week
    end
    # puts summary
    weeks.scoring_summary_puts
  end
end
