class Season < ApplicationRecord
  has_many :weeks, -> { order(:sequence) }, foreign_key: :season_year, primary_key: :year
  has_many :player_seasons
  has_many :players, through: :player_seasons

  validates :year, presence: true, uniqueness: { scope: :season_type }
  validates :season_type, presence: true
  validates :name, presence: true

  def self.s2025
    find_by(year: 2025, season_type: :nfl)
  end
  def self.s2024
    find_by(year: 2024, season_type: :nfl)
  end

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

  def self.sport_radar_season(year=2024)

    season = find_or_initialize_by(year: year)
    season.season_type = :nfl
    season.name = "#{year} NFL Season"
    season.save!

    # api_key = 'dBqzgfZiBp0sTpz06FIx3AjcLzCA2EzwFID6ZCl0' # amcr
    # api_key = 'xtsJqdNDRcvoGeXZ5kcG7iVYVJkpX4umc8bxIoGh' # free@b
    # api_key = 'HmAyXEUSsvWllyEVSCaniv3cnq8cLxKExAr2oAQD' # laurenalexm@g
    api_key = 'c9IaDr6BFd7tSrQdEDbtIclRe6gqHexujsLdevJw' # alex@boodle
    # Fetch data from SportRadar API
    response = HTTParty.get(
      "https://api.sportradar.com/nfl/official/trial/v7/en/games/#{year}/REG/schedule.json",
      headers: {
        'accept' => 'application/json',
        'x-api-key' => api_key
      }
    )

    if response.success?
      json_data = JSON.parse(response.body)
      json_data['weeks'].each do |week_data|
        puts "Week #{week_data['sequence']} - #{year}"
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
          venue = game_data['venue']
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
          # Puts game description
          puts "#{game.away_team.emoji} #{game.away_team.name.ljust(23)} @ #{game.home_team.emoji} #{game.home_team.name.ljust(23)} | #{venue['city'].rjust(15)} | #{venue['name'].rjust(15)} " 
          sleep(0.2)
        end
      end
    else
      puts "margot - Response Error"
      puts "Response: #{response.code}"
      puts "Response: #{response.body}"
      ap response
      puts "--------------------------------"
      sleep(30)
    end
  end
end 