module RankingConcern
  extend ActiveSupport::Concern

  class_methods do

    def receiver_core_rankings
      teams = includes(:team)
        .where.not(wr1: nil, wr2: nil, wr3: nil, te: nil)
      
      rankings = teams.map do |team|
        {
          score:      team.receiver_score,
          team:       team.team,
          receivers:  team.top_three_receivers,
        }
      end
      
      # Sort by score in descending order
      rankings.sort_by { |ranking| -ranking[:score] }
    end

    def qb_rankings
      teams = includes(:team).where.not(qb: nil)
      teams.map do |team|
        {
          score:  team.qb_player.passing_grade_x,
          team:   team.team,
          qb:     team.qb_player,
        }
      end.sort_by { |ranking| -ranking[:score] }
    end

    def rushing_rankings
      includes(:team).map do |team|
        {
          score: team.rushing_score,
          team: team.team,
          rushers: team.rushing_players
        }
      end.sort_by { |ranking| -ranking[:score] }
    end

    def oline_pass_block_rankings
      teams = includes(:team).where.not(c: nil, lg: nil, rg: nil, lt: nil, rt: nil)
      teams.map do |team|
        {
          score:  team.pass_block_score,
          team:   team.team,
          roster: team,
          qb:     team.qb_player,
          oline:  team.oline_players
        }
      end.sort_by { |ranking| -ranking[:score] }
    end

    def oline_run_block_rankings
      teams = includes(:team).where.not(c: nil, lg: nil, rg: nil, lt: nil, rt: nil)
      teams.map do |team|
        {
          score: team.rush_block_score,
          team: team.team,
          roster: team,
          oline: team.oline_players
        }
      end.sort_by { |ranking| -ranking[:score] }
    end

    def run_defense_rankings
      includes(:team).map do |team|
        {
          score: team.run_defense_score,
          team: team.team,
          roster: team,
          run_defense: team.defense_starters
        }
      end.sort_by { |ranking| -ranking[:score] }
    end

    def pass_rush_rankings
      includes(:team).map do |team|
        {
          score: team.pass_rush_score,
          team: team.team,
          roster: team,
          dline: team.dline_players
        }
      end.sort_by { |ranking| -ranking[:score] }
    end

    def coverage_rankings
      includes(:team).map do |team|
        {
          score: team.coverage_score,
          team: team.team,
          roster: team,
          secondary: team.secondary_players
        }
      end.sort_by { |ranking| -ranking[:score] }
    end


    def ranked_by_coach_metric(play_caller_field, rank_field, order_direction: 'ASC')
      table_name = self.table_name
      includes(:team)
        .where.not(play_caller_field => nil)
        .joins("LEFT JOIN coaches ON coaches.slug = #{table_name}.#{play_caller_field}")
        .order("coaches.#{rank_field} #{order_direction} NULLS LAST")
    end

    def ranked_by_offensive_play_caller_rank
      ranked_by_coach_metric(:offensive_play_caller, :offensive_play_caller_rank)
    end

    def ranked_by_defensive_play_caller
      ranked_by_coach_metric(:defensive_play_caller, :defensive_play_caller_rank)
    end

    def ranked_by_field_goal_rank
      ranked_by_coach_metric(:offensive_play_caller, :field_goal_rank)
    end

    def ranked_by_pace_of_play
      ranked_by_coach_metric(:offensive_play_caller, :pace_of_play_rank)
    end

    def ranked_by_run_heavy
      ranked_by_coach_metric(:offensive_play_caller, :run_heavy_rank)
    end
  end


  # Instance method to calculate total offense grade for top three receivers
  def top_three_receivers_grade
    top_three_receivers.sum { |player| player.receiving_grade_x || 60 }
  end

  # QB
  def qb_passing_rank
    return @_qb_passing_rank if defined?(@_qb_passing_rank)
    ranked_teams = self.class.qb_rankings
    team_ranking = ranked_teams.find { |ranking| ranking[:team] == self.team }
    @_qb_passing_rank = team_ranking ? ranked_teams.index(team_ranking) + 1 : nil
  end
  # RB
  def rushing_rank
    return @_rushing_rank if defined?(@_rushing_rank)
    ranked_teams = self.class.rushing_rankings
    team_ranking = ranked_teams.find { |ranking| ranking[:team] == self.team }
    @_rushing_rank = team_ranking ? ranked_teams.index(team_ranking) + 1 : nil
  end
  # WR, TE
  def receiver_core_rank
    return @_receiver_core_rank if defined?(@_receiver_core_rank)
    ranked_teams = self.class.receiver_core_rankings
    team_ranking = ranked_teams.find { |ranking| ranking[:team] == self.team }
    @_receiver_core_rank = team_ranking ? ranked_teams.index(team_ranking) + 1 : nil
  end
  # O-Line
  def oline_pass_block_rank
    return @_oline_pass_block_rank if defined?(@_oline_pass_block_rank)
    ranked_teams = self.class.oline_pass_block_rankings
    team_ranking = ranked_teams.find { |ranking| ranking[:team] == self.team }
    @_oline_pass_block_rank = team_ranking ? ranked_teams.index(team_ranking) + 1 : nil
  end
  def oline_run_block_rank
    return @_oline_run_block_rank if defined?(@_oline_run_block_rank)
    ranked_teams = self.class.oline_run_block_rankings
    team_ranking = ranked_teams.find { |ranking| ranking[:team] == self.team }
    @_oline_run_block_rank = team_ranking ? ranked_teams.index(team_ranking) + 1 : nil
  end
  # EDGE, DT, LB
  def pass_rush_rank
    return @_pass_rush_rank if defined?(@_pass_rush_rank)
    ranked_teams = self.class.pass_rush_rankings
    team_ranking = ranked_teams.find { |ranking| ranking[:team] == self.team }
    @_pass_rush_rank = team_ranking ? ranked_teams.index(team_ranking) + 1 : nil
  end
  # CB, S
  def coverage_rank
    return @_coverage_rank if defined?(@_coverage_rank)
    ranked_teams = self.class.coverage_rankings
    team_ranking = ranked_teams.find { |ranking| ranking[:team] == self.team }
    @_coverage_rank = team_ranking ? ranked_teams.index(team_ranking) + 1 : nil
  end
  def run_defense_rank
    return @_run_defense_rank if defined?(@_run_defense_rank)
    ranked_teams = self.class.run_defense_rankings
    team_ranking = ranked_teams.find { |ranking| ranking[:team] == self.team }
    @_run_defense_rank = team_ranking ? ranked_teams.index(team_ranking) + 1 : nil
  end
  # Offensive Play Caller
  def offensive_play_caller_rank
    return @_offensive_play_caller_rank if defined?(@_offensive_play_caller_rank)
    ranked_teams = self.class.ranked_by_offensive_play_caller_rank
    team_ranking = ranked_teams.index(self)
    @_offensive_play_caller_rank = team_ranking ? team_ranking + 1 : nil
  end
  def field_goal_caller_rank
    return @_field_goal_caller_rank if defined?(@_field_goal_caller_rank)
    ranked_teams = self.class.ranked_by_field_goal_rank
    team_ranking = ranked_teams.index(self)
    @_field_goal_caller_rank = team_ranking ? team_ranking + 1 : nil
  end
  def pace_of_play_rank
    return @_pace_of_play_rank if defined?(@_pace_of_play_rank)
    ranked_teams = self.class.ranked_by_pace_of_play
    team_ranking = ranked_teams.index(self)
    @_pace_of_play_rank = team_ranking ? team_ranking + 1 : nil
  end
  def run_heavy_rank
    return @_run_heavy_rank if defined?(@_run_heavy_rank)
    ranked_teams = self.class.ranked_by_run_heavy
    team_ranking = ranked_teams.index(self)
    @_run_heavy_rank = team_ranking ? team_ranking + 1 : nil
  end
  # Defensive Play Caller
  def defensive_play_caller_rank
    return @_defensive_play_caller_rank if defined?(@_defensive_play_caller_rank)
    ranked_teams = self.class.ranked_by_defensive_play_caller
    team_ranking = ranked_teams.index(self)
    @_defensive_play_caller_rank = team_ranking ? team_ranking + 1 : nil
  end
end 