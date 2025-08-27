class TeamsWeek < ApplicationRecord
  include PlayerRosterConcern
  # include ScoringConcern
  # include RankingConcern
  
  belongs_to :team, primary_key: :slug, foreign_key: :team_slug, optional: true

  validates :team_slug, :season_year, :week_number, presence: true

  # Starting lineup attributes: qb, rb1, rb2, wr1, wr2, wr3, te, c, lt, rt, lg, rg (offense)
  # eg1, eg2, dl1, dl2, dl3, lb1, lb2, cb1, cb2, cb3, s1, s2 (defense)
  # Coach attributes: hc (head coach), oc (offensive coordinator), dc (defensive coordinator)

  # Coach methods
  def head_coach_coach
    Coach.find_by_slug(head_coach)
  end
  def offensive_coordinator_coach
    Coach.find_by_slug(offensive_coordinator)
  end
  def defensive_coordinator_coach
    Coach.find_by_slug(defensive_coordinator)
  end
  def offensive_play_caller_coach
    Coach.find_by_slug(offensive_play_caller)
  end
  def defensive_play_caller_coach
    Coach.find_by_slug(defensive_play_caller)
  end
  def coaches
    Coach.where(slug: [head_coach, offensive_coordinator, defensive_coordinator, offensive_play_caller, defensive_play_caller].compact)
  end
  def self.offensive_play_callers
    Coach.where(slug: all.pluck(:offensive_play_caller).flatten.compact)
  end
  def self.defensive_play_callers
    Coach.where(slug: all.pluck(:defensive_play_caller).flatten.compact)
  end

  # Individual player methods are now provided by PlayerRosterConcern

  # TeamsWeek-specific collection methods
  def bench_players
    roster_players = Player.where(team_slug: team_slug)
    starter_slugs = (offense_starters + defense_starters).map(&:slug).compact
    roster_players.where.not(slug: starter_slugs)
  end

  def self.qbs
    Player.where(slug: all.pluck(:qb).flatten.compact)
  end
  
  def self.receivers
    Player.where(slug: all.pluck(:wr1, :wr2, :wr3, :te).flatten.compact)
  end



  def self.pass_rush_position_weight(position)
    case position
    when 'edge-rusher'
      1.0  # EDGE
    when 'defensive-end'
      0.7  # DT
    when 'linebacker'
      0.4  # LB
    when 'safety', 'cornerback'
      0.2  # CB/S
    else
      0.5  # Default weight for unknown positions
    end
  end



  # Scopes for filtering by season and week
  scope :by_season, ->(season) { where(season_year: season) }
  scope :by_week, ->(week) { where(week_number: week) }
  scope :by_season_and_week, ->(season, week) { where(season_year: season, week_number: week) }
end
