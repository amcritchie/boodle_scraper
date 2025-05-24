namespace :seasons do
  desc "Populate seasons (Kaggle)"
  task populate: :environment do
    # 60s | 2024 → 2017 (2016 has San Diego Chargers)
    Game.scrape_last(8)
  end
end
