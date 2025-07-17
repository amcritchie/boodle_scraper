namespace :seed do
  desc "Populate teams (Kaggle)"
  task gtm: :environment do
    
    # rake teams:populate                 | Fetch Teams         | Kaggle | 32 Teams
    Rake::Task['teams:populate'].invoke
    # rake seasons:matchups               | Fetch Games 2025    | Sports Radar | 2025 | Coming matchups
    Rake::Task['seasons:populate_2025'].invoke
    # rake players:populate               | Fetch Players       | Pro Football Focus | Player Stats
    Rake::Task['players:populate'].invoke
    # rake coaches:populate               | Set Coach Ranks     | 32 Coaches
    Rake::Task['coaches:populate'].invoke
    # rake teams:roster                   | Init 2025 Rosters   | Sports Radar | +1600 Players
    Rake::Task['teams:roster'].invoke
    # rake matchups:populate_2025_week_1  | Set Week 1 Matchups | Sports Radar | 2025 | Coming matchups
    Rake::Task['matchups:populate_2025_week_1'].invoke
 

    # Init 2024 - 2020 seasons
    Rake::Task['seasons:populate_2024_2020'].invoke
    Rake::Task['matchups:populate_2024_2020'].invoke
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
