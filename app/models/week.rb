class Week < ApplicationRecord
  has_many :games, ->(week) { where(season: week.season_year, week_slug: week.sequence) }

  def games
    return 'no-sports-radar-id' if sportsradar_id.blank?
    Game.where(season: season_year, week_slug: sequence).where.not(sportsradar_id: nil)
  end

  @@only_one_game = false

  def sport_radar_week
      puts "================================================"
      puts "Week #{self.sequence.to_s.rjust(2)} #{self.season_year}"
      # Initialize week population
      self.initialize_population

      # Each through games in week
      self.games.each do |game|

        # next unless game.slug == "sf-ari-18-2024" # Just one game

        # Iterate game count
        self.games_count += 1
        self.save!

        # # Generate matchups
        # game.away_matchup
        # game.home_matchup

        game.sport_radar_play_by_play_seed

        sleep(1)
        # Only process game
        break if @@only_one_game
      end
  end

  def initialize_population
    self.games_count              = 0
    self.rushing_touchdowns       = 0
    self.passing_touchdowns       = 0
    self.defensive_touchdowns     = 0
    self.special_teams_touchdowns = 0
    self.field_goals              = 0
    self.extra_points             = 0 # 1pt
    self.two_point_conversions    = 0
    self.interceptions            = 0 # 1pt
    self.fumbles                  = 0 # 1pt
    self.sacks                    = 0 # 1pt
    self.save!
  end

  def self.scoring_summary
    csv = ['games,season,week,field_goals,rushing_tds,passing_tds,defensive_tds,special_teams_tds']
    all.each do |week|
      # Get per game stats
      field_goals_per_game              = (week.field_goals.to_f / week.games_count).round(2)
      rushing_touchdowns_per_game       = (week.rushing_touchdowns.to_f / week.games_count).round(2)
      passing_touchdowns_per_game       = (week.passing_touchdowns.to_f / week.games_count).round(2)
      defensive_touchdowns_per_game     = (week.defensive_touchdowns.to_f / week.games_count).round(2)
      special_teams_touchdowns_per_game = (week.special_teams_touchdowns.to_f / week.games_count).round(2)
      # Push to CSV
      csv.push("#{week.games_count.to_i},#{week.season_year.to_i},#{week.sequence.to_i},#{field_goals_per_game},#{rushing_touchdowns_per_game},#{passing_touchdowns_per_game},#{defensive_touchdowns_per_game},#{special_teams_touchdowns_per_game}")
    end
      puts csv.join("\n")
  end

  def self.scoring_summary_puts
    puts "----------------"
    ap Week.last
    puts "----------------"
    all.each do |week|
      puts "Week #{week.sequence} #{week.season_year}"
      puts "Rushing Touchdowns:       #{week.rushing_touchdowns}"
      puts "Passing Touchdowns:       #{week.passing_touchdowns}"
      puts "Defensive Touchdowns:     #{week.defensive_touchdowns}"
      puts "Special Teams Touchdowns: #{week.special_teams_touchdowns}"
      puts "Field Goals:              #{week.field_goals}"
      puts "Extra Points:             #{week.extra_points}"
      puts "Games:                    #{week.games_count}"
    end
  end
end