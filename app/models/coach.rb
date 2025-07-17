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

  private
  def set_slug
    return if slug.present?
    base = [position, first_name, last_name].compact.join('-').parameterize
    self.slug = base.presence
  end
end 