class TeamsSeason < ApplicationRecord
  belongs_to :team, primary_key: :slug, foreign_key: :team_slug, optional: true

  validates :team_slug, :season_year, presence: true

  # Starting lineup attributes: o1-o11 (offense), d1-d11 (defense)
  # Coach attributes: hc (head coach), oc (offensive coordinator), dc (defensive coordinator)

  # Example: Fetch player objects for each position (future expansion)
  # def offense_starters
  #   Player.where(slug: [o1, o2, o3, o4, o5, o6, o7, o8, o9, o10, o11])
  # end
  # def defense_starters
  #   Player.where(slug: [d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11])
  # end
end 