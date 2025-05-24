namespace :teams do
  desc "Populate teams (Kaggle)"
  task populate: :environment do
    # 10s | Kaggle | Import teams from CSV
    Team.kaggle_import
  end
end
