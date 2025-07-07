namespace :seasons do

  desc "Populate 2024-2020 season (Sport Radar)"
  task populate_2024_2020: :environment do
    # 60s | 2021 → 2024 
    Season.sport_radar_season(2024)
    Season.sport_radar_season(2023)
    Season.sport_radar_season(2022)
    Season.sport_radar_season(2021)
    Season.sport_radar_season(2020)
  end

  desc "Populate 2024 season (Sport Radar)"
  task populate_2024: :environment do
    # 60s | 2024
    Season.sport_radar_season(2024)
  end

  desc "Populate 2024 -> 2017 seasons (Sports Odds History)"
  task populate_2024_2017: :environment do
    # 60s | 2024 → 2017 (2016 has San Diego Chargers)
    Game.scrape_last(2)
  end
end
