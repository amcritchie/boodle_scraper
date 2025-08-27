namespace :seed do
  desc "Populate teams (Kaggle)"
  task gtm: :environment do
    
    # rake teams:populate                     | Create Teams (Kaggle)                       | Kaggle | 32 Teams
    Rake::Task['teams:populate'].invoke
    # rake seasons:populate2025               | Create Season, Week, Games (Sports Radar)   | Sports Radar | 2025 | Coming matchups
    Rake::Task['seasons:populate2025'].invoke
    # rake players:populate                   | Create Players (PFF Grades)                 | Pro Football Focus | Player Stats
    Rake::Task['players:populate'].invoke
    # rake coaches:populate                   | Create Coaches (HC, OC, DC)                 | 32 Coaches
    Rake::Task['coaches:populate'].invoke
    Rake::Task['coaches:populate_defensive_play_caller_ranks'].invoke
    Rake::Task['coaches:populate_pace_of_play_ranks'].invoke
    Rake::Task['coaches:populate_run_heavy_ranks'].invoke
    Rake::Task['coaches:populate_field_goal_ranks'].invoke
    # rake teams:starters2025                 | TeamsSeasons (Rookie Starters)      | Team Starters 2025  | Pro Football Focus | 2025
    Rake::Task['teams:starters2025'].invoke
    # rake teams:modifyGrades2025             | TeamsSeasons (Rookie Grades) Set Coach Ranks         | 32 Coaches
    Rake::Task['teams:modifyGrades2025'].invoke
    # rake teams:roster2025                   | TeamsSeasons Coaches (Spoorts Radar) | Sports Radar | +1600 Players
    Rake::Task['teams:roster2025'].invoke
    # rake teams:startersOveride2025          | Players (Left Handed QB) | Sports Radar | +1600 Players
    Rake::Task['teams:startersOveride2025'].invoke
    # rake teams:startersCurrent              | TeamsSeasons (ESPN Depth Scraper) | Sports Radar | +1600 Players
    Rake::Task['teams:startersCurrent'].invoke
    # rake teams_weeks:populate_2025_week_1  | TeamsWeeks (Sports Radar) | 2025 | Rankings and Scores
    Rake::Task['teams_weeks:populate_2025_week_1'].invoke

    # Run Oline ranking
    Rake::Task['rankings:populate_oline_rankings'].invoke

    # rake matchups:populate_2025_week_1      | Matchups (Sports Radar) | Sports Radar | 2025 | Coming matchups
    Rake::Task['matchups:populate_2025_week_1'].invoke
 

    # Init 2024 - 2020 seasons
    # Rake::Task['seasons:populate_2024_2020'].invoke
    # Rake::Task['matchups:populate_2024_2020'].invoke
    # # Init 2024
    # Rake::Task['seasons:populate_2024'].invoke
    # Rake::Task['matchups:populate_2024'].invoke

    # # rake players:populate | Kaggle | 10s
    # Rake::Task['contracts:populate'].invoke
    # # rake matchups:populate
    # Rake::Task['matchups:populate'].invoke
    # # rake matchups:populate2025
    # Rake::Task['matchups:populate2025'].invoke
  end
end
