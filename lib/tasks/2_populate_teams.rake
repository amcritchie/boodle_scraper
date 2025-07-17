namespace :teams do
  desc "Populate 32 Active Teams (Kaggle)"
  task populate: :environment do
    Team.kaggle_import_teams
  end

  desc "Populate Current Roster for Active Teams (Sport Radar)"
  task rosterr: :environment do
    Team.active.reverse.each do |team| 
      team.fetch_roster_sportradar
    end
  end

  desc "Populate TeamsSeason with current starters and coaches"
  task roster: :environment do
    puts "Populating TeamsSeason with current starters and coaches..."
    Team.active.each do |team|
      team.fetch_roster_sportradar

      # puts "2025 Roster added #{team.name.rjust(22)} #{team.emoji} | Players: #{team.players.length.to_s.rjust(4)} | QB: #{team.starting_qb.player.ljust(40)} | Play caller: #{team.offensive_play_caller.full_name.ljust(40)}"
      sleep(0.5)
      offense = team.generate_offense
      defense = team.generate_defense
      head_coach = Coach.find_by(team_slug: team.slug, season: 2025, position: 'Head Coach')
      offensive_coordinator = Coach.find_by(team_slug: team.slug, season: 2025, position: 'Offensive Coordinator')
      defensive_coordinator = Coach.find_by(team_slug: team.slug, season: 2025, position: 'Defensive Coordinator')
      teams_season = TeamsSeason.find_or_create_by(team_slug: team.slug, season_year: 2025)
      teams_season.update(
        o1:   offense[:quarterback]&.slug,
        o2:   offense[:runningback]&.slug,
        o3:   offense[:wide_receivers][0]&.slug,
        o4:   offense[:wide_receivers][1]&.slug,
        o5:   offense[:tight_end]&.slug,
        o6:   offense[:flex]&.slug,
        o7:   offense[:oline][0]&.slug,
        o8:   offense[:oline][1]&.slug,
        o9:   offense[:oline][2]&.slug,
        o10:  offense[:oline][3]&.slug,
        o11:  offense[:oline][4]&.slug,
        d1:   defense[:defensive_ends][0]&.slug,
        d2:   defense[:defensive_ends][1]&.slug,
        d3:   defense[:edge_rushers][0]&.slug,
        d4:   defense[:edge_rushers][1]&.slug,
        d5:   defense[:linebackers][0]&.slug,
        d6:   defense[:linebackers][1]&.slug,
        d7:   defense[:safeties][0]&.slug,
        d8:   defense[:safeties][1]&.slug,
        d9:   defense[:cornerbacks][0]&.slug,
        d10:  defense[:cornerbacks][1]&.slug,
        d11:  defense[:flex]&.slug,
        hc:   head_coach&.slug,
        oc:   offensive_coordinator&.slug,
        dc:   defensive_coordinator&.slug
      )
      play_caller_emoji = "🧠" if team.offensive_play_caller.position == "Offensive Coordinator"
      play_caller_emoji = "🏈" if team.offensive_play_caller.position == "Head Coach"
      # puts "2025 Roster added #{team.name.rjust(22)} #{team.emoji} | Players: #{team.players.length.to_s.rjust(4)} | QB: #{team.starting_qb.player.ljust(40)}"
      puts "TeamsSeason updated for #{team.name.rjust(22)} #{team.emoji} | QB: #{offense[:quarterback]&.player&.ljust(20)} | Play caller: #{team.offensive_play_caller.full_name&.ljust(20)} #{play_caller_emoji}"
    end
    puts "\nTeamsSeason population completed!"
    puts "Total TeamsSeason records: #{TeamsSeason.count}"
  end
end 