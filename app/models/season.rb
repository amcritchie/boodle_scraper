class Season < ApplicationRecord
  has_many :weeks
  has_many :player_seasons
  has_many :players, through: :player_seasons

  validates :year, presence: true, uniqueness: { scope: :season_type }
  validates :season_type, presence: true
  validates :name, presence: true

  def increment_passing_touchdowns!(amount = 1)
    increment!(:passing_touchdowns, amount)
  end

  def increment_rushing_touchdowns!(amount = 1)
    increment!(:rushing_touchdowns, amount)
  end

  def increment_field_goals!(amount = 1)
    increment!(:field_goals, amount)
  end

  def increment_total_touchdowns!(amount = 1)
    increment!(:total_touchdowns, amount)
  end

  def increment_total_scoring_plays!(amount = 1)
    increment!(:total_scoring_plays, amount)
  end

  def self.sportsradar_import(season=2024)
    season_json = "lib/sportradar/2024-season-schedule.json"
    json_data = JSON.parse(File.read(Rails.root.join(season_json)))
    
    # Create or update the season record
    season_record = find_or_initialize_by(
      year: json_data['year'],
      season_type: json_data['type']
    )
    
    season_record.name = json_data['name']
    season_record.save!
    
    season_record
  end

  def self.sport_radar(year=2024)
    # Fetch data from SportRadar API
    response = HTTParty.get(
      "https://api.sportradar.com/nfl/official/trial/v7/en/games/#{year}/REG/schedule.json",
      headers: {
        'accept' => 'application/json',
        'x-api-key' => 'dBqzgfZiBp0sTpz06FIx3AjcLzCA2EzwFID6ZCl0'
      }
    )
    
    if response.success?
      json_data = JSON.parse(response.body)
      json_data['weeks'].each do |week_data|
        puts "Week #{week_data['sequence']}"
        puts "---"
        # Find or create week
        unless week = Week.find_by(sportsradar_id: week_data['id'])
          week = Week.find_or_create_by(season_year: year, sequence: week_data['sequence'])
        end
        # Update week
        week.update!(  
          season_year: year,
          sequence: week_data['sequence'],
          sportsradar_id: week_data['id'],
          title: week_data['title']
        )
        # Each through games
        week_data['games'].each do |game_data|
          # Parse Teams and Games
          home_team = Team.sports_radar_team(game_data['home']['alias'])
          away_team = Team.sports_radar_team(game_data['away']['alias'])
          puts "Home Team: #{home_team.name}"
          puts "Away Team: #{away_team.name}"
          puts "---"
          ap game_data['venue']
          puts "---"
          # Create slug for the game
          slug = "#{away_team.slug}-#{home_team.slug}-#{week.sequence}-#{year}".downcase
          scheduled = DateTime.parse(game_data['scheduled'])
          # Find or create game
          unless game = Game.find_by(sportsradar_id: game_data['id'])
            unless game = Game.find_by(sportsradar_slug: game_data['sr_id'])
              game = Game.find_or_create_by(slug: slug)
            end
          end
          # Update game
          game.update!(
            sportsradar_id:   game_data['id'],
            sportsradar_slug: game_data['sr_id'],
            season:           year,
            week_slug:        week_data['sequence'],
            away_slug:        away_team.slug,
            home_slug:        home_team.slug,
            scheduled:        game_data['scheduled'],
            attendance:       game_data['attendance'],
            date:             scheduled.to_date,
            day_of_week:      scheduled.strftime('%A'),
            start_time:       scheduled.strftime('%I:%M %p')
          )
          # Puts game
          ap game
        end
      
      # # Create or update the season record
      # season_record = find_or_initialize_by(
      #   year: json_data['year'],
      #   season_type: json_data['type']
      # )
      
      # season_record.name = json_data['name']
      # season_record.save!

      # # Process each week
      # json_data['weeks'].each do |week_data|
      #   # Create or update week
      #   week = Week.find_or_initialize_by(
      #     season: season_record,
      #     sequence: week_data['sequence'],
      #     title: week_data['title']
      #   )
      #   week.save!

      #   # Process each game in the week
      #   week_data['games'].each do |game_data|
      #     # Create or update venue
      #     venue = Venue.find_or_initialize_by(
      #       name: game_data['venue']['name'],
      #       city: game_data['venue']['city'],
      #       state: game_data['venue']['state'],
      #       country: game_data['venue']['country']
      #     )
      #     venue.update!(
      #       zip: game_data['venue']['zip'],
      #       address: game_data['venue']['address'],
      #       capacity: game_data['venue']['capacity'],
      #       surface: game_data['venue']['surface'],
      #       roof_type: game_data['venue']['roof_type'],
      #       sr_id: game_data['venue']['sr_id']
      #     )

      #     # Create or update game
      #     game = Game.find_or_initialize_by(
      #       source: :sportradar,
      #       season: year,
      #       week_slug: week.sequence.to_s,
      #       slug_sportsradar: game_data['id']
      #     )

      #     # Update game attributes
      #     game.update!(
      #       title: "#{game_data['away']['name']} @ #{game_data['home']['name']}",
      #       scheduled: game_data['scheduled'],
      #       status: game_data['status'],
      #       attendance: game_data['attendance'],
      #       entry_mode: game_data['entry_mode'],
      #       game_type: game_data['home']['source']&.dig('game_type') || 'regular',
      #       conference_game: game_data['conference_game'],
      #       duration: game_data['duration'],
      #       home_slug: game_data['home']['alias']&.downcase,
      #       away_slug: game_data['away']['alias']&.downcase,
      #       venue_slug: venue.name.parameterize,
      #       kickoff_at: game_data['scheduled'],
      #       date: game_data['scheduled'].to_date,
      #       start_time: game_data['scheduled'].strftime('%I:%M %p'),
      #       day_of_week: game_data['scheduled'].strftime('%A'),
      #       primetime: %w[Thursday Monday Sunday].include?(game_data['scheduled'].strftime('%A')) || 
      #                 game_data['scheduled'].strftime('%I:%M %p').include?('8:20') ||
      #                 game_data['scheduled'].strftime('%I:%M %p').include?('8:15')
      #     )

      #     # Create or update broadcast information
      #     if game_data['broadcast'].present?
      #       broadcast = Broadcast.find_or_initialize_by(game: game)
      #       broadcast.update!(
      #         network: game_data['broadcast']['network'],
      #         satellite: game_data['broadcast']['satellite'],
      #         internet: game_data['broadcast']['internet'],
      #         radio: game_data['broadcast']['radio']
      #       )
      #     end

      #     # Create or update weather information
      #     if game_data['weather'].present?
      #       weather = Weather.find_or_initialize_by(game: game)
      #       weather.update!(
      #         condition: game_data['weather']['condition'],
      #         temperature: game_data['weather']['temp'],
      #         humidity: game_data['weather']['humidity'],
      #         wind_speed: game_data['weather']['wind']['speed'],
      #         wind_direction: game_data['weather']['wind']['direction']
      #       )
      #     end

      #     # Create or update scoring information
      #     if game_data['scoring'].present?
      #       scoring = Scoring.find_or_initialize_by(game: game)
      #       scoring.update!(
      #         home_points: game_data['scoring']['home_points'],
      #         away_points: game_data['scoring']['away_points']
      #       )

      #       # Process periods (quarters and overtime)
      #       game_data['scoring']['periods'].each do |period_data|
      #         period = scoring.periods.find_or_initialize_by(
      #           period_type: period_data['period_type'],
      #           number: period_data['number'],
      #           sequence: period_data['sequence']
      #         )
      #         period.update!(
      #           home_points: period_data['home_points'],
      #           away_points: period_data['away_points']
      #         )
      #       end
      #     end

      #     puts "🏈 Game imported: #{game.season} | Week #{game.week_slug} | #{game.away_slug} at #{game.home_slug}"
        # end
      end

      # season_record
    else
      Rails.logger.error "Failed to fetch SportRadar schedule: #{response.code} - #{response.message}"
      nil
    end
  end
end 