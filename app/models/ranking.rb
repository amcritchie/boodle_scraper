class Ranking < ApplicationRecord
  belongs_to :player, primary_key: :slug, foreign_key: :player_slug, optional: true
  
  # Scopes
  scope :by_ranking_slug, ->(slug) { where(ranking_slug: slug) }
  scope :by_week, ->(week) { where(week: week) }
  scope :by_player, ->(player_slug) { where(player_slug: player_slug) }
  scope :by_position, ->(position) { where(position: position) }
  scope :with_player, -> { joins(:player) }
  scope :with_valid_player, -> { where.not(player_slug: nil).joins(:player) }
  
  # Find rankings for a specific ranking set
  def self.find_rankings(ranking_slug)
    by_ranking_slug(ranking_slug).includes(:player).order(:rank_1, :rank_2, :rank_3)
  end
  
  # Get player's rank in a specific category
  def rank_for_category(category)
    case category.to_s
    when 'offense'
      rank_1
    when 'pass_block'
      rank_2
    when 'run_block'
      rank_3
    else
      nil
    end
  end
  
  # Calculate percentile from rank
  def percentile_for_category(category)
    rank = rank_for_category(category)
    return nil unless rank
    
    total_players = self.class.by_ranking_slug(ranking_slug).count
    (rank / total_players.to_f * 100).round(1)
  end
end
