namespace :seasons do
  
  desc "Populate 2021-2024 season (Sport Radar)"
  task populate2021t2024: :environment do
    # 60s | 2021 → 2024 
    # Season.sport_radar(2024)
    # Season.sport_radar(2023)
    Season.sport_radar(2022)
    Season.sport_radar(2021)
    Season.sport_radar(2020)
  end
  desc "Populate 2024 season (Sport Radar)"
  task populate2024: :environment do
    # 60s | 2024 → 2017 (2016 has San Diego Chargers)
    # Season.sport_radar(2024)
    Season.sport_radar(2023)
  end
  desc "Populate 2017 -> 2024 seasons (Sports Odds History)"
  task populate2017: :environment do
    # 60s | 2024 → 2017 (2016 has San Diego Chargers)
    Game.scrape_last(2)
  end
end
