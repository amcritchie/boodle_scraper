class PlayerSeason < ApplicationRecord
  belongs_to :player
  belongs_to :season
  belongs_to :team, optional: true

  validates :player_id, uniqueness: { scope: :season_id }
  validates :passing_touchdowns, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :rushing_touchdowns, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :receiving_touchdowns, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :field_goals_made, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :tackles, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :interceptions, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :sacks, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :return_touchdowns, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end 