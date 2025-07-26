class Coach < ApplicationRecord
  validates :team_slug, presence: true
  validates :season, presence: true
  validates :slug, uniqueness: true, presence: true

  belongs_to :team, primary_key: :slug, foreign_key: :team_slug, optional: true

  before_validation :set_slug

  scope :offensive_coordinators, -> { where(position: 'Offensive Coordinator') }
  scope :head_coaches, -> { where(position: 'Head Coach') }
  scope :by_season, ->(season) { where(season: season) }
  scope :by_play_caller_rank, -> { order(:offensive_play_caller_rank) }
  scope :by_pace_rank, -> { order(:pace_of_play_rank) }
  scope :by_run_heavy_rank, -> { order(:run_heavy_rank) }
  scope :current_season, -> { by_season(2025) }

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def offensive_play_caller?
    position&.include?('Offensive') || position&.include?('Head Coach')
  end

  def self.pace
    by_pace_rank.each{ |coach| puts "#{coach.pace_of_play_rank} | #{coach.team_slug} | #{coach.full_name}" }
    return by_pace_rank.first
  end
  def self.run_heavy
    by_run_heavy_rank.each{ |coach| puts "#{coach.run_heavy_rank} | #{coach.team_slug} | #{coach.full_name}" }
    return by_run_heavy_rank.first
  end
  def self.play_caller
    by_play_caller_rank.each{ |coach| puts "#{coach.offensive_play_caller_rank} | #{coach.team_slug} | #{coach.full_name}" }
    return by_play_caller_rank.first
  end

  def self.calculate_field_goal_attack_scores(matchups, season = 2025)
    field_goal_attack_scores = []
    
    matchups.each do |matchup|
      # Get the offensive play caller for each team
      home_coach = where(team_slug: matchup.team_slug, season: season)
                   .where.not(offensive_play_caller_rank: nil)
                   .first
      away_coach = where(team_slug: matchup.team_defense_slug, season: season)
                   .where.not(offensive_play_caller_rank: nil)
                   .first
      
      # Calculate field goal attack score based on coach field goal ranks
      # Lower field_goal_rank = better kicker = better field goal attack
      home_fg_rank = home_coach&.field_goal_rank || 32
      away_fg_rank = away_coach&.field_goal_rank || 32
      
      # Better field goal rank (lower number) = better field goal attack
      field_goal_attack_score = (33 - home_fg_rank) - (33 - away_fg_rank)
      
      field_goal_attack_scores << {
        matchup: matchup,
        score: field_goal_attack_score,
        home_coach: home_coach,
        away_coach: away_coach,
        home_fg_rank: home_fg_rank,
        away_fg_rank: away_fg_rank
      }
    end
    
    field_goal_attack_scores
  end

  def self.assign_field_goal_ranks(matchups, season = 2025)
    scores = calculate_field_goal_attack_scores(matchups, season)
    
    # Sort by score (descending) and assign ranks
    scores.sort_by! { |item| -item[:score] }
    
    scores.each_with_index do |item, index|
      item[:matchup].update(field_goal_rank: index + 1)
    end
    
    scores
  end

  private
  def set_slug
    return if slug.present?
    base = [position, first_name, last_name].compact.join('-').parameterize
    self.slug = base.presence
  end
end 