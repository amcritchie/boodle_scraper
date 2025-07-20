class TeamsSeason < ApplicationRecord
  belongs_to :team, primary_key: :slug, foreign_key: :team_slug, optional: true

  validates :team_slug, :season_year, presence: true

  # Starting lineup attributes: qb, rb1, rb2, wr1, wr2, wr3, te, c, lt, rt, lg, rg (offense)
  # eg1, eg2, dl1, dl2, dl3, lb1, lb2, cb1, cb2, cb3, s1, s2 (defense)
  # Coach attributes: hc (head coach), oc (offensive coordinator), dc (defensive coordinator)

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

  def off_play_caller
    Coach.find_by_slug(offensive_play_caller)
  end

  def def_play_caller
    Coach.find_by_slug(defensive_play_caller)
  end

  # Collection methods
  def offense_starters
    Player.where(slug: [qb, rb1, rb2, wr1, wr2, wr3, te, c, lt, rt, lg, rg].compact)
  end

  def defense_starters
    Player.where(slug: [eg1, eg2, dl1, dl2, dl3, lb1, lb2, cb1, cb2, cb3, s1, s2].compact)
  end

  def coaches
    Coach.where(slug: [hc, oc, dc, offensive_play_caller, defensive_play_caller].compact)
  end

  def self.play_callers
    Coach.where(slug: all.pluck(:offensive_play_caller).flatten.compact)
  end

  def self.qbs
    Player.where(slug: all.pluck(:qb).flatten.compact)
  end

  def self.receivers
    Player.where(slug: all.pluck(:wr1, :wr2, :wr3, :te).flatten.compact)
  end

  def receivers
    Player.where(slug: [wr1, wr2, wr3, te].compact)
  end

  # Ranking methods for the view
  def self.ranked_by_play_caller
    includes(:team)
      .where.not(oc: nil)
      .joins('LEFT JOIN coaches ON coaches.slug = teams_seasons.offensive_play_caller')
      .order('coaches.offensive_play_caller_rank ASC NULLS LAST')
  end

  def self.ranked_by_pace_of_play
    includes(:team)
      .where.not(oc: nil)
      .joins('LEFT JOIN coaches ON coaches.slug = teams_seasons.offensive_play_caller')
      .order('coaches.pace_of_play_rank ASC NULLS LAST')
  end

  def self.ranked_by_run_heavy
    includes(:team)
      .where.not(oc: nil)
      .joins('LEFT JOIN coaches ON coaches.slug = teams_seasons.offensive_play_caller')
      .order('coaches.run_heavy_rank ASC NULLS LAST')
  end

  def self.ranked_by_qb_passing
    includes(:team)
      .where.not(qb: nil)
      .joins('LEFT JOIN players ON players.slug = teams_seasons.qb')
      .order('players.passing_grade DESC NULLS LAST')
  end

  def self.receiver_core_rankings
    teams_seasons = includes(:team)
      .where.not(wr1: nil, wr2: nil, te: nil)
      .joins('LEFT JOIN players wr1_player ON wr1_player.slug = teams_seasons.wr1')
      .joins('LEFT JOIN players wr2_player ON wr2_player.slug = teams_seasons.wr2')
      .joins('LEFT JOIN players te_player ON te_player.slug = teams_seasons.te')
      .select('teams_seasons.*, 
               (COALESCE(wr1_player.grades_offense, 60) + 
                COALESCE(wr2_player.grades_offense, 60) + 
                COALESCE(te_player.grades_offense, 60)) as total_offense_grade')
      .order('total_offense_grade DESC')
    
    teams_seasons.map do |team_season|
      {
        total_offense_grade: team_season.total_offense_grade,
        team: team_season.team,
        receivers: [
          team_season.wr1_player,
          team_season.wr2_player,
          team_season.te_player
        ].compact
      }
    end
  end

  def receiver_score
    receiver_score =  0
    recs = receivers.by_grades_offense.limit(4)
    ap self
    ap recs
    ap receivers
    ap recs.second
    # 1st Receiver
    receiver_score += 1.0*recs.first.grades_offense
    # 2nd Receiver
    receiver_score += 0.6*recs.second.grades_offense
    # 3rd Receiver
    receiver_score += 0.4*recs.third.grades_offense rescue 60
    # 4th Receiver
    receiver_score += 0.2*recs.fourth.grades_offense rescue 60
    # Return reciever score
    receiver_score.to_i
  end

  def self.receiver_rankings
    all.map do |team_season|
      {
        receiver_score: team_season.receiver_score,
        team: team_season.team,
        receivers: team_season.receivers.by_grades_pass_route.limit(4)
      }
    end.sort_by { |ranking| -ranking[:receiver_score] }
  end

  def oline_players
      Player.where(slug: [c, lg, rg, lt, rt].compact)
    # [
    #   center_player,
    #   left_guard_player,
    #   right_guard_player,
    #   left_tackle_player,
    #   right_tackle_player
    # ].compact
  end

  def dline_players
    Player.where(slug: [eg1, eg2, dl1, dl2, dl3].compact)
    # [
    #   edge1_player,
    #   edge2_player,
    #   dl1_player,
    #   dl2_player,
    #   dl3_player
    # ].compact
  end

  def secondary_players
    [
      safety1_player,
      safety2_player,
      cb1_player,
      cb2_player,
      cb3_player
    ].compact
  end

  def rushing_players
    # Get all potential rushing players and sort by rushing grade
    potential_rushers = [rb1_player, rb2_player, qb_player, te_player].compact
    potential_rushers.sort_by { |player| -(player.rushing_grade || 0) }.first(2)
  end

  def pass_block_score
    pass_block_score = 0
    oline = oline_players.by_grades_pass_block.limit(5)
    
    # Center (most important for pass blocking)
    pass_block_score += 1.0 * oline.first.grades_pass_block rescue 60
    # Left Tackle (protects QB's blind side)
    pass_block_score += 0.9 * oline.second.grades_pass_block rescue 60
    # Right Tackle
    pass_block_score += 0.8 * oline.third.grades_pass_block rescue 60
    # Left Guard
    pass_block_score += 0.7 * oline.fourth.grades_pass_block rescue 60
    # Right Guard
    pass_block_score += 0.6 * oline.fifth.grades_pass_block rescue 60
    
    pass_block_score.to_i
  end

  def self.pass_block_rankings
    all.map do |team_season|
      {
        pass_block_score: team_season.pass_block_score,
        team: team_season.team,
        oline: team_season.oline_players.by_grades_pass_block.limit(5)
      }
    end.sort_by { |ranking| -ranking[:pass_block_score] }
  end

  def self.oline_pass_block_rankings
    teams_seasons = includes(:team)
      .where.not(c: nil, lg: nil, rg: nil, lt: nil, rt: nil)
    
    teams_seasons.map do |team_season|
      total_pass_block_grade = team_season.oline_players.sum { |player| player.grades_pass_block || 60 }
      {
        total_pass_block_grade: total_pass_block_grade,
        team: team_season.team,
        oline: team_season.oline_players
      }
    end.sort_by { |ranking| -ranking[:total_pass_block_grade] }
  end

  def self.oline_run_block_rankings
    teams_seasons = includes(:team)
      .where.not(c: nil, lg: nil, rg: nil, lt: nil, rt: nil)
    
    teams_seasons.map do |team_season|
      total_run_block_grade = team_season.oline_players.sum { |player| player.grades_run_block || 60 }
      {
        total_run_block_grade: total_run_block_grade,
        team: team_season.team,
        oline: team_season.oline_players
      }
    end.sort_by { |ranking| -ranking[:total_run_block_grade] }
  end

  def self.pass_rush_rankings
    teams_seasons = includes(:team)
      .where.not(eg1: nil, eg2: nil, dl1: nil, dl2: nil, dl3: nil)
    
    teams_seasons.map do |team_season|
      total_pass_rush_grade = team_season.dline_players.sum { |player| (player.pass_rush_grade || 60) * pass_rush_position_weight(player.position) }
      {
        total_pass_rush_grade: total_pass_rush_grade,
        team: team_season.team,
        dline: team_season.dline_players
      }
    end.sort_by { |ranking| -ranking[:total_pass_rush_grade] }
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

  def self.coverage_rankings
    teams_seasons = includes(:team)
      .where.not(s1: nil, s2: nil, cb1: nil, cb2: nil, cb3: nil)
    
    teams_seasons.map do |team_season|
      total_coverage_grade = team_season.secondary_players.sum { |player| player.coverage_grade || 60 }
      {
        total_coverage_grade: total_coverage_grade,
        team: team_season.team,
        secondary: team_season.secondary_players
      }
    end.sort_by { |ranking| -ranking[:total_coverage_grade] }
  end

  def self.run_defense_rankings
    teams_seasons = includes(:team)
      .where.not(eg1: nil, eg2: nil, dl1: nil, dl2: nil, dl3: nil, lb1: nil, lb2: nil, s1: nil, s2: nil)
    
    teams_seasons.map do |team_season|
      all_defense_players = team_season.dline_players + team_season.secondary_players + [team_season.lb1_player, team_season.lb2_player].compact
      total_run_defense_grade = all_defense_players.sum { |player| player.rush_defense_grade || 60 }
      {
        total_run_defense_grade: total_run_defense_grade,
        team: team_season.team,
        defense: all_defense_players
      }
    end.sort_by { |ranking| -ranking[:total_run_defense_grade] }
  end

  def self.rushing_rankings
    teams_seasons = includes(:team)
      .where.not(qb: nil, rb1: nil) # At least need QB and RB1
    
    teams_seasons.map do |team_season|
      top_rushers = team_season.rushing_players
      total_rushing_grade = top_rushers.sum { |player| player.grades_run || 60 }
      {
        total_rushing_grade: total_rushing_grade,
        team: team_season.team,
        rushers: top_rushers
      }
    end.sort_by { |ranking| -ranking[:total_rushing_grade] }
  end

  def play_caller_rank
    ranked_teams = self.class.ranked_by_play_caller
    rank = ranked_teams.index(self)
    rank ? rank + 1 : nil
  end

  def pace_of_play_rank
    ranked_teams = self.class.ranked_by_pace_of_play
    rank = ranked_teams.index(self)
    rank ? rank + 1 : nil
  end

  def run_heavy_rank
    ranked_teams = self.class.ranked_by_run_heavy
    rank = ranked_teams.index(self)
    rank ? rank + 1 : nil
  end

  def qb_passing_rank
    ranked_teams = self.class.ranked_by_qb_passing
    rank = ranked_teams.index(self)
    rank ? rank + 1 : nil
  end

  def receiver_core_rank
    ranked_teams = self.class.receiver_core_rankings
    team_ranking = ranked_teams.find { |ranking| ranking[:team] == self.team }
    team_ranking ? ranked_teams.index(team_ranking) + 1 : nil
  end

  def pass_block_rank
    ranked_teams = self.class.pass_block_rankings
    team_ranking = ranked_teams.find { |ranking| ranking[:team] == self.team }
    team_ranking ? ranked_teams.index(team_ranking) + 1 : nil
  end

  def oline_pass_block_rank
    ranked_teams = self.class.oline_pass_block_rankings
    team_ranking = ranked_teams.find { |ranking| ranking[:team] == self.team }
    team_ranking ? ranked_teams.index(team_ranking) + 1 : nil
  end

  def oline_run_block_rank
    ranked_teams = self.class.oline_run_block_rankings
    team_ranking = ranked_teams.find { |ranking| ranking[:team] == self.team }
    team_ranking ? ranked_teams.index(team_ranking) + 1 : nil
  end

  def pass_rush_rank
    ranked_teams = self.class.pass_rush_rankings
    team_ranking = ranked_teams.find { |ranking| ranking[:team] == self.team }
    team_ranking ? ranked_teams.index(team_ranking) + 1 : nil
  end

  def coverage_rank
    ranked_teams = self.class.coverage_rankings
    team_ranking = ranked_teams.find { |ranking| ranking[:team] == self.team }
    team_ranking ? ranked_teams.index(team_ranking) + 1 : nil
  end

  def run_defense_rank
    ranked_teams = self.class.run_defense_rankings
    team_ranking = ranked_teams.find { |ranking| ranking[:team] == self.team }
    team_ranking ? ranked_teams.index(team_ranking) + 1 : nil
  end

  def rushing_rank
    ranked_teams = self.class.rushing_rankings
    team_ranking = ranked_teams.find { |ranking| ranking[:team] == self.team }
    team_ranking ? ranked_teams.index(team_ranking) + 1 : nil
  end
end 