namespace :init do
  desc "Initialized Next Week"
  task nextWeek: :environment do
    $week = 2 
    season = Season.find_by(year: 2025)

    # rake teams:startersCurrent              | TeamsSeasons (ESPN Depth Scraper) | Sports Radar | +1600 Players
    Rake::Task['teams:startersCurrent'].invoke
    # rake teams_weeks:populate_2025_week_1  | TeamsWeeks (Sports Radar) | 2025 | Rankings and Scores
    Rake::Task['teams_weeks:populate_2025_week_1'].invoke

    # rake rankings:populate_oline_rankings
    # rake rankings:populate_qb_rankings
    Rake::Task['rankings:populate_oline_rankings'].invoke
    Rake::Task['rankings:populate_qb_rankings'].invoke

    # rake matchups:populate_2025_week_1      | Matchups (Sports Radar) | Sports Radar | 2025 | Coming matchups
    Rake::Task['matchups:populate_2025_week_1'].invoke

    # Get scores for NFL Week 1
    # rake matchups:week_1_scores      | Matchups (Sports Radar) | Sports Radar | 2025 | Coming matchups
    Rake::Task['matchups:week_1_scores'].invoke
    
  end

  desc "Initialize Season 2025"
  task season2025: :environment do
    season = Season.find_by(year: 2025)

    # rake seasons:populate2025                       | Create Season, Week, Games, Venue (Sports Radar)   | Sports Radar | 2025 | Coming matchups
    Rake::Task['seasons:populate2025'].invoke
    # rake players:pff_player_grades                  | Create Players (PFF Grades)                 | Pro Football Focus | Player Stats
    Rake::Task['players:pff_player_grades'].invoke
    # rake coaches:populate                           | Create Coaches (HC, OC, DC)                 | 32 Coaches
    Rake::Task['coaches:populate'].invoke
    Rake::Task['coaches:populate_defensive_play_caller_ranks'].invoke
    Rake::Task['coaches:populate_pace_of_play_ranks'].invoke
    Rake::Task['coaches:populate_run_heavy_ranks'].invoke
    Rake::Task['coaches:populate_field_goal_ranks'].invoke
    # rake teams:starters2025                         | TeamsSeasons (Rookie Starters)      | Team Starters 2025  | Pro Football Focus | 2025
    Rake::Task['teams:starters2025'].invoke
    # rake teams:modifyGrades2025                     | TeamsSeasons (Rookie Grades) Set Coach Ranks         | 32 Coaches
    Rake::Task['teams:modifyGrades2025'].invoke
    # rake teams:roster2025                           | TeamsSeasons Coaches (Spoorts Radar) | Sports Radar | +1600 Players
    Rake::Task['teams:roster2025'].invoke
    # rake teams:startersOveride2025                  | Players (Left Handed QB) | Sports Radar | +1600 Players
    Rake::Task['teams:startersOveride2025'].invoke

    # First Week ===========================
    # rake init:nextWeek                              | Current Starters, Teams Weeks, Matchups, Rankings
    Rake::Task['init:nextWeek'].invoke

  end

  desc "Init application"
  task application: :environment do
    
    # rake teams:populate                     | Initialize Teams (Kaggle, Custom) | 32 Teams + TeamPopulations attributes 
    Rake::Task['teams:populate'].invoke
    # rake venue:populate                     | Create Venues (Sports Radar)               | Sports Radar | 32 Venues
    Rake::Task['venue:populate'].invoke

    # Season ===========================
    # rake init:season2025                    | Create Season, Week, Games, Venue (Sports Radar)   | Sports Radar | 2025 | Coming matchups
    Rake::Task['init:season2025'].invoke
  end
end
