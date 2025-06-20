namespace :teams do
  desc "Populate teams (Kaggle)"
  task populate: :environment do
    # 10s | Kaggle | Import teams from CSV
    Team.kaggle_import_teams
  end

  desc "Populate 2024 Roster for active teams (Sport Radar)"
  task roster2024: :environment do
    # 10s | Kaggle | Import teams from CSV
    Team.active.reverse.each do |team| 
      team.fetch_roster_sportradar
      # Puts roster info
      puts "2024 Roster added #{team.name.rjust(22)} #{team.emoji} | Players: #{team.players.length.to_s.rjust(4)} | QBs: #{team.players.quarterbacks.select(:last_name).pluck("last_name").join(", ").ljust(40)}"
      sleep(0.5)
    end
  end
end
