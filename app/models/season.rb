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
end 