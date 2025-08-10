class TeamsSeason < ApplicationRecord
  include ScoringConcern
  include RankingConcern
  
  belongs_to :team, primary_key: :slug, foreign_key: :team_slug, optional: true

  validates :team_slug, :season_year, presence: true

  has_many :teams_weeks, ->(team_season) { where(season_year: team_season.season_year) }, primary_key: :team_slug, foreign_key: :team_slug

  # Starting lineup attributes: qb, rb1, rb2, wr1, wr2, wr3, te, c, lt, rt, lg, rg (offense)
  # eg1, eg2, dl1, dl2, dl3, lb1, lb2, cb1, cb2, cb3, s1, s2 (defense)
  # Coach attributes: hc (head coach), oc (offensive coordinator), dc (defensive coordinator)

  # Coach methods
  def head_coach
    Coach.find_by_slug(hc)
  end
  def offensive_coordinator
    Coach.find_by_slug(oc)
  end
  def defensive_coordinator
    Coach.find_by_slug(dc)
  end
  def offensive_play_caller_coach
    Coach.find_by_slug(offensive_play_caller)
  end
  def defensive_play_caller_coach
    Coach.find_by_slug(defensive_play_caller)
  end
  def coaches
    Coach.where(slug: [hc, oc, dc, offensive_play_caller, defensive_play_caller].compact)
  end
  def self.offensive_play_callers
    Coach.where(slug: all.pluck(:offensive_play_caller).flatten.compact)
  end
  def self.defensive_play_callers
    Coach.where(slug: all.pluck(:defensive_play_caller).flatten.compact)
  end

  # Player methods
  def qb_player
    Player.find_by_slug(qb)
  end
  def rb1_player
    Player.find_by_slug(rb1)
  end
  def rb2_player
    Player.find_by_slug(rb2)
  end
  def wr1_player
    Player.find_by_slug(wr1)
  end
  def wr2_player
    Player.find_by_slug(wr2)
  end
  def wr3_player
    Player.find_by_slug(wr3)
  end
  def te_player
    Player.find_by_slug(te)
  end
  def center_player
    Player.find_by_slug(c)
  end
  def left_tackle_player
    Player.find_by_slug(lt)
  end
  def right_tackle_player
    Player.find_by_slug(rt)
  end
  def left_guard_player
    Player.find_by_slug(lg)
  end
  def right_guard_player
    Player.find_by_slug(rg)
  end
  def edge1_player
    Player.find_by_slug(eg1)
  end
  def edge2_player
    Player.find_by_slug(eg2)
  end
  def dl1_player
    Player.find_by_slug(dl1)
  end
  def dl2_player
    Player.find_by_slug(dl2)
  end
  def dl3_player
    Player.find_by_slug(dl3)
  end
  def lb1_player
    Player.find_by_slug(lb1)
  end
  def lb2_player
    Player.find_by_slug(lb2)
  end
  def cb1_player
    Player.find_by_slug(cb1)
  end
  def cb2_player
    Player.find_by_slug(cb2)
  end
  def cb3_player
    Player.find_by_slug(cb3)
  end
  def safety1_player
    Player.find_by_slug(s1)
  end
  def safety2_player
    Player.find_by_slug(s2)
  end


  # Collection methods
  def offense_starters
    Player.where(slug: [qb, rb1, rb2, wr1, wr2, wr3, te, c, lt, rt, lg, rg].compact)
  end
  def defense_starters
    Player.where(slug: [eg1, eg2, dl1, dl2, dl3, lb1, lb2, cb1, cb2, cb3, s1, s2].compact)
  end
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

  def rushers
    Player.where(slug: [qb, rb1, rb2].compact)
  end
  def receivers
    Player.where(slug: [wr1, wr2, wr3, te].compact)
  end
  def top_three_receivers
    Player.where(slug: receivers.sort_by { |player| -(player.receiving_grade_x || 0) }.first(3).pluck(:slug))
  end
  def oline_players
    slugs = [lt, lg, c, rg, rt].compact
    players = Player.where(slug: slugs)
    # Sort players to match the order of slugs in the original array
    players.sort_by { |player| slugs.index(player.slug) }
  end
  def edge_players
    Player.where(slug: [eg1, eg2].compact)
  end
  def dinterior_players
    Player.where(slug: [dl1, dl2, dl3].compact).sort_by { |player| -(player.rush_defense_grade_x || 0) }
  end
  def dline_players
    Player.where(slug: [eg1, eg2, dl1, dl2, dl3].compact)
  end
  def pass_rush_players
    Player.where(slug: dline_players.sort_by { |player| -(player.pass_rush_grade_x || 0) }.pluck(:slug))
  end
  def linebacker_players
    Player.where(slug: [lb1, lb2].compact).sort_by { |player| -(player.rush_defense_grade_x || 0) }
  end
  def corner_back_players
    Player.where(slug: [cb1, cb2, cb3]).sort_by { |player| -(player.coverage_grade_x || 0) }
  end
  def safety_players
    Player.where(slug: [s1, s2]).sort_by { |player| -(player.coverage_grade_x || 0) }
  end
  def secondary_players
    Player.where(slug: [cb1, cb2, cb3, s1, s2].compact)
  end

  def rushing_players
    # Get all potential rushing players and sort by rushing grade
    potential_rushers = [rb1_player, rb2_player, qb_player].compact
    potential_rushers.sort_by { |player| -(player.rush_grade_x || 0) }.first(2)
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
end 