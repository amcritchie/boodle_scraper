namespace :seed do
  desc "Populate teams (Kaggle)"
  task gtm: :environment do
    
    # rake teams:populate               | Kaggle | 32 Teams
    Rake::Task['teams:populate'].invoke
    # rake teams:roster2024             | Sports Radar | 32 Teams
    Rake::Task['teams:roster2024'].invoke
      # # rake players:populate         | Pro Football Focus | Player Stats
    Rake::Task['players:populate'].invoke

    one_season = true 
    
    if one_season
      # rake seasons:populate             | Sports Radar | 2024
      Rake::Task['seasons:populate2024'].invoke
      # rake seasons:matchups             | Sports Radar | 2024
      Rake::Task['matchups:populate2024'].invoke
    else
      # rake seasons:populate             | Sports Radar | 2024, 2023, 2022, 2021
      Rake::Task['seasons:populate2021t2024'].invoke
      # rake seasons:matchups             | Sports Radar | 2024, 2023, 2022, 2021
      Rake::Task['matchups:populate2021t2024'].invoke
    end
    # Rake::Task['seasons:populate2021t2024'].invoke
    # rake seasons:populate             | Sports Odds History | 2017 - 2024
    # Rake::Task['seasons:populate2017'].invoke

    # rake seasons:matchups             | Sports Radar | 2024 | Past matchups
    # Rake::Task['matchups:populate2024'].invoke
    # Rake::Task['matchups:populate2021t2024'].invoke
    # rake seasons:matchups             | Sports Radar | 2025 | Coming matchups
    # Rake::Task['seasons:matchups2025'].invoke


    # # # rake players:populate | Kaggle | 10s
    # # Rake::Task['contracts:populate'].invoke
    # # rake matchups:populate
    # Rake::Task['matchups:populate'].invoke
    # rake matchups:populate2025
    # Rake::Task['matchups:populate2025'].invoke
  end
end
