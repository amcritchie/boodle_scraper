namespace :seasons do
  
  desc "Populate 2024 season (Sport Radar)"
  task populate2024: :environment do
    # 60s | 2024 → 2017 (2016 has San Diego Chargers)
    Season.sport_radar(2024)
  end
  desc "Populate 2017 -> 2024 seasons (Sports Odds History)"
  task populate2017: :environment do
    # 60s | 2024 → 2017 (2016 has San Diego Chargers)
    Game.scrape_last(2)
  end
end
