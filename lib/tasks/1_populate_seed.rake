namespace :seed do
  desc "Populate teams (Kaggle)"
  task gtm: :environment do
    
    # rake teams:populate               | Kaggle | 32 Teams
    Rake::Task['teams:populate'].invoke
    # rake teams:roster                 | Sports Radar | +2900 Players (Add Final Rosters for 2025 season)
    Rake::Task['teams:roster'].invoke
      # # rake players:populate         | Pro Football Focus | Player Stats
    Rake::Task['players:populate'].invoke

    # rake coaches:populate             | Manual | 32 Coaches (Add Final Rosters for 2025 season)
    Rake::Task['coaches:populate'].invoke

    # Init 2024 - 2020 seasons
    Rake::Task['seasons:populate_2024_2020'].invoke
    Rake::Task['matchups:populate_2024_2020'].invoke
    # # Init 2024
    # Rake::Task['seasons:populate_2024'].invoke
    # Rake::Task['matchups:populate_2024'].invoke


    # rake seasons:matchups             | Sports Radar | 2025 | Coming matchups
    # Rake::Task['seasons:matchups2025'].invoke


    # # rake players:populate | Kaggle | 10s
    # Rake::Task['contracts:populate'].invoke
    # rake matchups:populate
    Rake::Task['matchups:populate'].invoke
    # rake matchups:populate2025
    Rake::Task['matchups:populate2025'].invoke
  end
end
