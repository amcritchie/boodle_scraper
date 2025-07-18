class TeamsSeason < ApplicationRecord
  belongs_to :team, primary_key: :slug, foreign_key: :team_slug, optional: true

  validates :team_slug, :season_year, presence: true

  # Starting lineup attributes: o1-o11 (offense), d1-d11 (defense)
  # Coach attributes: hc (head coach), oc (offensive coordinator), dc (defensive coordinator)

  # Player methods
  def qb
    Player.find_by_slug(o1)
  end

  def rb
    Player.find_by_slug(o2)
  end

  def wr1
    Player.find_by_slug(o3)
  end

  def wr2
    Player.find_by_slug(o4)
  end

  def te
    Player.find_by_slug(o5)
  end

  def flex
    Player.find_by_slug(o6)
  end

  def center
    Player.find_by_slug(o7)
  end

  def left_guard
    Player.find_by_slug(o8)
  end

  def right_guard
    Player.find_by_slug(o9)
  end

  def left_tackle
    Player.find_by_slug(o10)
  end

  def right_tackle
    Player.find_by_slug(o11)
  end

  def de1
    Player.find_by_slug(d1)
  end

  def de2
    Player.find_by_slug(d2)
  end

  def edge1
    Player.find_by_slug(d3)
  end

  def edge2
    Player.find_by_slug(d4)
  end

  def lb1
    Player.find_by_slug(d5)
  end

  def lb2
    Player.find_by_slug(d6)
  end

  def safety1
    Player.find_by_slug(d7)
  end

  def safety2
    Player.find_by_slug(d8)
  end

  def cb1
    Player.find_by_slug(d9)
  end

  def cb2
    Player.find_by_slug(d10)
  end

  def def_flex
    Player.find_by_slug(d11)
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
    Player.where(slug: [o1, o2, o3, o4, o5, o6, o7, o8, o9, o10, o11])
  end

  def defense_starters
    Player.where(slug: [d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11])
  end

  def coaches
    Coach.where(slug: [hc, oc, dc, offensive_play_caller, defensive_play_caller].compact)
  end

  def self.play_callers
    Coach.where(slug: all.pluck(:offensive_play_caller).flatten.compact)
  end

  def self.qbs
    Player.where(slug: all.pluck(:o1).flatten.compact)
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
      .where.not(o1: nil)
      .joins('LEFT JOIN players ON players.slug = teams_seasons.o1')
      .order('players.passing_grade DESC NULLS LAST')
  end

  def self.receiver_core_rankings
    teams_seasons = includes(:team)
      .where.not(o3: nil, o4: nil, o5: nil)
      .joins('LEFT JOIN players wr1_player ON wr1_player.slug = teams_seasons.o3')
      .joins('LEFT JOIN players wr2_player ON wr2_player.slug = teams_seasons.o4')
      .joins('LEFT JOIN players te_player ON te_player.slug = teams_seasons.o5')
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
          team_season.wr1,
          team_season.wr2,
          team_season.te
        ].compact
      }
    end
  end

  def oline_players
    [
      center,
      left_guard,
      right_guard,
      left_tackle,
      right_tackle
    ].compact
  end

  def dline_players
    [
      de1,
      de2,
      edge1,
      edge2
    ].compact
  end

  def secondary_players
    [
      safety1,
      safety2,
      cb1,
      cb2
    ].compact
  end

  def rushing_players
    # Get all potential rushing players and sort by rushing grade
    potential_rushers = [rb, qb, flex, te].compact
    potential_rushers.sort_by { |player| -(player.rushing_grade || 0) }.first(2)
  end

  def self.oline_pass_block_rankings
    teams_seasons = includes(:team)
      .where.not(o7: nil, o8: nil, o9: nil, o10: nil, o11: nil)
    
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
      .where.not(o7: nil, o8: nil, o9: nil, o10: nil, o11: nil)
    
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
      .where.not(d1: nil, d2: nil, d3: nil, d4: nil)
    
    teams_seasons.map do |team_season|
      total_pass_rush_grade = team_season.dline_players.sum { |player| player.pass_rush_grade || 60 }
      {
        total_pass_rush_grade: total_pass_rush_grade,
        team: team_season.team,
        dline: team_season.dline_players
      }
    end.sort_by { |ranking| -ranking[:total_pass_rush_grade] }
  end

  def self.coverage_rankings
    teams_seasons = includes(:team)
      .where.not(d7: nil, d8: nil, d9: nil, d10: nil)
    
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
      .where.not(d1: nil, d2: nil, d3: nil, d4: nil, d5: nil, d6: nil, d7: nil, d8: nil)
    
    teams_seasons.map do |team_season|
      all_defense_players = team_season.dline_players + team_season.secondary_players
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
      .where.not(o1: nil, o2: nil) # At least need QB and RB
    
    teams_seasons.map do |team_season|
      top_rushers = team_season.rushing_players
      total_rushing_grade = top_rushers.sum { |player| player.grades_run|| 60 }
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