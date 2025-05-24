namespace :seed do
  desc "Populate teams (Kaggle)"
  task gtm: :environment do
    
    # rake teams:populate
    Rake::Task['teams:populate'].invoke
    # rake seasons:populate
    Rake::Task['seasons:populate'].invoke
    # rake players:populate
    Rake::Task['players:populate'].invoke
    # # rake players:populate
    # Rake::Task['contracts:populate'].invoke
    # rake matchups:populate
    Rake::Task['matchups:populate'].invoke
    # rake matchups:populate2025
    Rake::Task['matchups:populate2025'].invoke
  end
end
