namespace :teams_weeks do
  desc "Populate TeamsWeek data for Week 1, Season 2025 with rankings and scores"
  task populate_2025_week_1: :environment do
    puts "Populating TeamsWeek data for Week 1, Season 2025..."
    
    # First pass: Populate basic data from TeamsSeason
    TeamsSeason.where(season_year: 2025).each do |team_season|
      # Create TeamsWeek record for week 1
      # team_week = team_season.teams_weeks.find_or_create_by(
      team_week = TeamsWeek.find_or_create_by(week_number: 1)
      
      # Copy all player data
      team_week.update(
        # Offensive players
        qb: team_season.qb,
        rb1: team_season.rb1,
        rb2: team_season.rb2,
        wr1: team_season.wr1,
        wr2: team_season.wr2,
        wr3: team_season.wr3,
        te: team_season.te,
        c: team_season.c,
        lt: team_season.lt,
        rt: team_season.rt,
        lg: team_season.lg,
        rg: team_season.rg,
        
        # Defensive players
        eg1: team_season.eg1,
        eg2: team_season.eg2,
        dl1: team_season.dl1,
        dl2: team_season.dl2,
        dl3: team_season.dl3,
        lb1: team_season.lb1,
        lb2: team_season.lb2,
        cb1: team_season.cb1,
        cb2: team_season.cb2,
        cb3: team_season.cb3,
        s1: team_season.s1,
        s2: team_season.s2,
        
        # Special teams
        place_kicker: team_season.place_kicker,
        punter: team_season.punter,
        
        # Coaches
        head_coach: team_season.hc,
        offensive_coordinator: team_season.oc,
        defensive_coordinator: team_season.dc,
        offensive_play_caller: team_season.offensive_play_caller,
        defensive_play_caller: team_season.defensive_play_caller,

        qb_score: team_season.qb_score,
        rushing_score: team_season.rushing_score,
        receiver_score: team_season.receiver_score,
        pass_block_score: team_season.pass_block_score,
        rush_block_score: team_season.rush_block_score,
        pass_rush_score: team_season.pass_rush_score,
        coverage_score: team_season.coverage_score,
        run_defense_score: team_season.run_defense_score,

        passing_offense_score: team_season.passing_offense_score,
        rushing_offense_score: team_season.rushing_offense_score,
        offense_score: team_season.offense_score,

        passing_defense_score: team_season.passing_defense_score,
        rushing_defense_score: team_season.rushing_defense_score,
        defense_score: team_season.defense_score,

        power_rank_score: team_season.power_rank_score,
        # field_goal_score: team_season.field_goal_score,
        
        # Additional scoring fields
        offensive_play_caller_score: team_season.offensive_play_caller_score,
        defensive_play_caller_score: team_season.defensive_play_caller_score,
        pace_of_play_score: team_season.pace_of_play_score,
        run_heavy_score: team_season.run_heavy_score,
        field_goal_score: team_season.field_goal_score,
      )
      
      puts "Created/Updated TeamsWeek for #{team_season.team&.name} - Week 1"
    end
    
    # Second pass: Calculate rankings and scores
    puts "Calculating rankings and scores..."

    # First pass: Populate basic data from TeamsSeason
    TeamsSeason.where(season_year: 2025).each do |team_season|
      # Create TeamsWeek record for week 1
      # team_week = team_season.teams_weeks.find_or_create_by(
      team_week = TeamsWeek.find_or_create_by(week_number: 1)
      
      # Copy all player data
      team_week.update(
        # Ranks
        offensive_play_caller_rank: team_season.offensive_play_caller_rank,
        defensive_play_caller_rank: team_season.defensive_play_caller_rank,
        pace_of_play_rank: team_season.pace_of_play_rank,
        run_heavy_rank: team_season.run_heavy_rank,
        qb_passing_rank: team_season.qb_passing_rank,
        receiver_core_rank: team_season.receiver_core_rank,
        pass_block_rank: team_season.oline_pass_block_rank,
        rush_block_rank: team_season.oline_run_block_rank,
        pass_rush_rank: team_season.pass_rush_rank,
        coverage_rank: team_season.coverage_rank,
        run_defense_rank: team_season.run_defense_rank,
        rushing_rank: team_season.rushing_rank,
        field_goal_rank: team_season.field_goal_caller_rank
      )

      puts "play_caller_rank:     #{team_week.offensive_play_caller_rank}"
      puts "pace_of_play_rank:    #{team_week.pace_of_play_rank}"
      puts "run_heavy_rank:       #{team_week.run_heavy_rank}"
      puts "qb_passing_rank:      #{team_week.qb_passing_rank}"
      puts "receiver_core_rank:   #{team_week.receiver_core_rank}"
      puts "pass_block_rank:      #{team_week.pass_block_rank}"
      puts "oline_run_block_rank: #{team_week.rush_block_rank}"
      puts "pass_rush_rank:       #{team_week.pass_rush_rank}"
      puts "coverage_rank:        #{team_week.coverage_rank}"
      puts "run_defense_rank:     #{team_week.run_defense_rank}"
      puts "rushing_rank:         #{team_week.rushing_rank}"
      puts "field_goal_rank:      #{team_week.field_goal_rank}"
      
      puts "Created/Updated TeamsWeek for #{team_season.team&.name} - Week 1"
    end
    
    # Get all teams_weeks for week 1
    all_teams_weeks = TeamsWeek.where(season_year: 2025, week_number: 1)
    
    puts "TeamsWeek population complete!"
    puts "Populated #{all_teams_weeks.count} teams for Week 1, Season 2025"
  end

  desc "Populate TeamsWeek data from TeamsSeason for week 1 (basic copy)"
  task populate_week1: :environment do
    puts "Populating TeamsWeek data for week 1..."
    
    TeamsSeason.where(season_year: 2025).each do |team_season|
      # Create TeamsWeek record for week 1
      team_week = TeamsWeek.find_or_create_by(
        team_slug: team_season.team_slug,
        season_year: team_season.season_year,
        week_number: 1
      )
      
      # Copy all player data
      team_week.update(
        # Offensive players
        qb: team_season.qb,
        rb1: team_season.rb1,
        rb2: team_season.rb2,
        wr1: team_season.wr1,
        wr2: team_season.wr2,
        wr3: team_season.wr3,
        te: team_season.te,
        c: team_season.c,
        lt: team_season.lt,
        rt: team_season.rt,
        lg: team_season.lg,
        rg: team_season.rg,
        
        # Defensive players
        eg1: team_season.eg1,
        eg2: team_season.eg2,
        dl1: team_season.dl1,
        dl2: team_season.dl2,
        dl3: team_season.dl3,
        lb1: team_season.lb1,
        lb2: team_season.lb2,
        cb1: team_season.cb1,
        cb2: team_season.cb2,
        cb3: team_season.cb3,
        s1: team_season.s1,
        s2: team_season.s2,
        
        # Special teams
        place_kicker: team_season.place_kicker,
        punter: team_season.punter,
        
        # Coaches
        head_coach: team_season.hc,
        offensive_coordinator: team_season.oc,
        defensive_coordinator: team_season.dc,
        offensive_play_caller: team_season.offensive_play_caller,
        defensive_play_caller: team_season.defensive_play_caller
      )
      
      puts "Created/Updated TeamsWeek for #{team_season.team&.name} - Week 1"
    end
    
    puts "TeamsWeek population complete!"
  end
end 