namespace :seed do
  desc "Populate teams (Kaggle)"
  task gtm: :environment do
    
    # rake teams:populate
    Rake::Task['teams:populate'].invoke
    # rake rosters:populate
    Rake::Task['seasons:populate'].invoke
    # rake players:populate
    Rake::Task['players:populate'].invoke
    # rake players:populate
    Rake::Task['contracts:populate'].invoke
    # rake rosters:populate
    Rake::Task['rosters:populate'].invoke
  end
end
