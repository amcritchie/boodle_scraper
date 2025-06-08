namespace :games do
  desc "Import games from the 2024 season schedule"
  task import_2024: :environment do
    require 'csv'

    # Find or create the 2024 season
    season = Season.find_or_create_by!(
      year: 2024,
      season_type: 'regular',
      name: '2024 NFL Regular Season'
    )

    # Read the CSV file
    csv_path = Rails.root.join('lib', 'data', '2024-season-schedule.csv')
    unless File.exist?(csv_path)
      puts "Error: Could not find schedule file at #{csv_path}"
      exit
    end

    CSV.foreach(csv_path, headers: true) do |row|
      # Parse the date and time
      date = Date.parse(row['Date'])
      time = row['Time_ET']
      scheduled = Time.parse("#{date} #{time}")

      # Find or create teams
      home_team = Team.find_by(name: row['Home'])
      away_team = Team.find_by(name: row['Visitor'])

      unless home_team && away_team
        puts "Warning: Could not find teams for game: #{row['Visitor']} @ #{row['Home']}"
        next
      end

      # Find or create venue
      venue = Venue.find_or_create_by!(
        name: "#{home_team.name} Stadium",
        city: row['City'],
        state: row['State'],
        country: 'USA'
      )

      # Find or create week
      week = Week.find_or_create_by!(
        season: season,
        sequence: row['Week'].to_i,
        title: "Week #{row['Week']}"
      )

      # Create the game
      game = Game.find_or_create_by!(
        week: week,
        home_team: home_team,
        away_team: away_team,
        venue: venue,
        scheduled: scheduled,
        status: 'scheduled',
        sr_id: "2024-#{row['Week']}-#{away_team.alias}-#{home_team.alias}",
        game_type: 'regular',
        conference_game: true,
        title: "#{away_team.name} @ #{home_team.name}"
      )

      # Create broadcast information if available
      if row['TV'].present?
        Broadcast.find_or_create_by!(
          game: game,
          network: row['TV']
        )
      end

      puts "Imported game: #{game.title} (Week #{week.sequence})"
    end

    puts "Finished importing 2024 season games!"
  end
end 