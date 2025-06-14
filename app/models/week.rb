class Week < ApplicationRecord
  # belongs_to :season
  # has_many :games

  # validates :sequence, presence: true, uniqueness: { scope: :season_year }
  # validates :title, presence: true

  def games
    return 'no-sports-radar-id' if sportsradar_id.blank?
    Game.where(season: season_year, week_slug: sequence).where.not(sportsradar_id: nil)
  end
end 