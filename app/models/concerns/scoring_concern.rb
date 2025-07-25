module ScoringConcern
  extend ActiveSupport::Concern

  class_methods do
    def receiver_rankings
      all.map do |team_season|
        {
          receiver_score: team_season.receiver_score,
          team: team_season.team,
          receivers: team_season.receivers.by_grades_pass_route.limit(4)
        }
      end.sort_by { |ranking| -ranking[:receiver_score] }
    end

    def pass_block_rankings
      all.map do |team_season|
        {
          pass_block_score: team_season.pass_block_score,
          team: team_season.team,
          oline: team_season.oline_players.by_grades_pass_block.limit(5)
        }
      end.sort_by { |ranking| -ranking[:pass_block_score] }
    end

    def run_block_rankings
      all.map do |team_season|
        {
          run_block_score: team_season.run_block_score,
          team: team_season.team,
          oline: team_season.oline_players.by_grades_run_block.limit(5)
        }
      end.sort_by { |ranking| -ranking[:run_block_score] }
    end

    def run_defense_rankings
      all.map do |team_season|
        {
          run_defense_score: team_season.run_defense_score,
          team: team_season.team,
          defense: team_season.run_defense_players
        }
      end.sort_by { |ranking| -ranking[:run_defense_score] }
    end

    def pass_rush_rankings
      all.map do |team_season|
        {
          pass_rush_score: team_season.pass_rush_score,
          team: team_season.team,
          dline: team_season.dline_players
        }
      end.sort_by { |ranking| -ranking[:pass_rush_score] }
    end

    def coverage_rankings
      all.map do |team_season|
        {
          coverage_score: team_season.coverage_score,
          team: team_season.team,
          secondary: team_season.secondary_players
        }
      end.sort_by { |ranking| -ranking[:coverage_score] }
    end

    def rushing_rankings
      all.map do |team_season|
        {
          rushing_score: team_season.rusher_score,
          team: team_season.team,
          rushers: team_season.rushing_players
        }
      end.sort_by { |ranking| -ranking[:rushing_score] }
    end
  end
  
  def rusher_score
    rusher_score = 0
    # 1st Rusher
    rusher_score += 1.0 * (rb1_player.grades_run || 60)
    # 2nd Rusher
    rusher_score += 0.3 * (qb_player.grades_run || 60)
    # Return rusher score
    rusher_score.to_f
  end
  
  def receiver_score
    receiver_score = 0
    recs = receivers.by_grades_offense.limit(4)
    # 1st Receiver
    receiver_score += 1.0 * recs.first.grades_offense
    # 2nd Receiver
    receiver_score += 0.7 * recs.second.grades_offense
    # 3rd Receiver
    receiver_score += 0.4 * (recs.third.grades_offense || 60)
    # 4th Receiver
    receiver_score += 0.2 * (recs.fourth.grades_offense || 60)
    # Return receiver score
    receiver_score.to_f
  end

  def pass_block_score
    pass_block_score = 0
    # Tackle importance depends on QB handedness
    unless qb_player&.left_handed
      # For right-handed QB: Left Tackle protects blind side (more important)
      pass_block_score += 1.0 * (left_tackle_player.grades_pass_block || 60)
      pass_block_score += 0.7 * (right_guard_player.grades_pass_block || 60)
      pass_block_score += 0.5 * (right_tackle_player.grades_pass_block || 60)
      pass_block_score += 0.5 * (left_guard_player.grades_pass_block || 60)
    else
      # For left-handed QB: Right Tackle protects blind side (more important)
      pass_block_score += 1.0 * (right_tackle_player.grades_pass_block || 60)
      pass_block_score += 0.7 * (left_guard_player.grades_pass_block || 60)
      pass_block_score += 0.5 * (left_tackle_player.grades_pass_block || 60)
      pass_block_score += 0.5 * (right_guard_player.grades_pass_block || 60)
    end
    # Center
    pass_block_score += 0.5 * (center_player.grades_pass_block || 60)
    # Return pass block score
    pass_block_score.to_f
  end

  def run_block_score
    run_block_score = 0
    
    # Center (most important for run blocking - makes calls and anchors the line)
    run_block_score += 1.0 * (center_player.grades_run_block || 60)
    # Left Guard (important for pulling and trap blocks)
    run_block_score += 0.9 * (left_guard_player.grades_run_block || 60)
    # Right Guard (important for pulling and trap blocks)
    run_block_score += 0.9 * (right_guard_player.grades_run_block || 60)
    # Left Tackle (important for sealing the edge)
    run_block_score += 0.8 * (left_tackle_player.grades_run_block || 60)
    # Right Tackle (important for sealing the edge)
    run_block_score += 0.8 * (right_tackle_player.grades_run_block || 60)
    
    # Return run block score
    run_block_score.to_f
  end

  def run_defense_score
    run_defense_score = 0
    # Get all defensive players involved in run defense
    all_defense_players = dline_players + secondary_players + [lb1_player, lb2_player].compact
    
    # Sort by run defense grade and take top players
    top_run_defenders = all_defense_players.sort_by { |player| -(player.grades_rush_defense || 0) }.first(8)
    
    # Weight the top run defenders (front 7 + 1 safety)
    top_run_defenders.each_with_index do |player, index|
      case index
      when 0..1  # Top 2 defenders (usually DTs/DEs)
        run_defense_score += 1.0 * (player.grades_rush_defense || 60)
      when 2..3  # Next 2 defenders (usually LBs)
        run_defense_score += 0.9 * (player.grades_rush_defense || 60)
      when 4..5  # Next 2 defenders (usually edge rushers)
        run_defense_score += 0.8 * (player.grades_rush_defense || 60)
      when 6..7  # Last 2 defenders (usually safeties)
        run_defense_score += 0.7 * (player.grades_rush_defense || 60)
      end
    end
    
    # Return run defense score
    run_defense_score.to_f
  end

  def pass_rush_score
    pass_rush_score = 0
    egdes = edge_players.by_grades_pass_rush
    dinterior = dinterior_players.by_grades_pass_rush
    # Get defensive line players and sort by pass rush grade
    pass_rushers = dline_players.sort_by { |player| -(player.grades_pass_rush || 0) }
    # Calculate pass rush score
    pass_rush_score += 1.0 * (egdes.first.grades_pass_rush || 60)
    pass_rush_score += 0.7 * (egdes.second.grades_pass_rush || 60)
    pass_rush_score += 0.7 * (dinterior.first.grades_pass_rush || 60)
    pass_rush_score += 0.5 * (dinterior.second.grades_pass_rush || 60)
    pass_rush_score += 4.5 * (dinterior.third.grades_pass_rush || 60)
    # Return pass rush score
    pass_rush_score.to_f
  end

  def coverage_score
    coverage_score = 0
    # Get secondary players and sort by coverage grade
    coverage_players = secondary_players.sort_by { |player| -(player.grades_coverage || 0) }
    
    # Weight coverage players by position importance
    coverage_players.each_with_index do |player, index|
      case player.position
      when 'cornerback'
        coverage_score += 1.0 * (player.grades_coverage || 60)
      when 'safety'
        coverage_score += 0.9 * (player.grades_coverage || 60)
      else
        coverage_score += 0.7 * (player.grades_coverage || 60)
      end
    end
    
    # Add linebacker coverage contribution
    [lb1_player, lb2_player].compact.each do |lb|
      coverage_score += 0.6 * (lb.grades_coverage || 0)
    end
    
    # Return coverage score
    coverage_score.to_f
  end

  def run_defense_players
    # Helper method to get all players involved in run defense
    dline_players + secondary_players + [lb1_player, lb2_player].compact
  end
end 