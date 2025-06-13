namespace :teams do
  desc "Populate teams (Kaggle)"
  task populate: :environment do
    # 10s | Kaggle | Import teams from CSV
    Team.kaggle_import_teams
  end

  desc "Populate 2024 Roster for active teams (Sport Radar)"
  task roster2024: :environment do
    # 10s | Kaggle | Import teams from CSV
    Team.active.each do |team| 
      team.fetch_roster_sportradar
      # Find and print player with highest player_game_count
      qbs = team.players.quarterbacks.select(:position, :first_name, :slug, :player_game_count).order(player_game_count: :desc)
      qb = team.players.quarterbacks.order(player_game_count: :desc)
      ap qb.first
      puts "---"
      ap qbs
      puts "\ QB player for #{team.name} (#{qbs.length}):"
      sleep(5)
    end
  end
end
