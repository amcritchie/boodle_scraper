module ScoringConcern
  extend ActiveSupport::Concern

  class_methods do
    # Class Methods
  end

  def offensive_play_caller_score
    score = 0
    # Normalize to 50-95 scale: (33-rank)/32 gives 0-1, then scale to 50-95
    normalized_score = 50 + 45*(33-offensive_play_caller_rank)/32
    score += normalized_score
    score.to_f
  end
  def defensive_play_caller_score
    score = 0
    # Normalize to 50-95 scale: (33-rank)/32 gives 0-1, then scale to 50-95
    normalized_score = 50 + 45*(33-defensive_play_caller_rank)/32
    score += normalized_score
    score.to_f
  end
  def pace_of_play_score
    score = 0
    # Normalize to 50-95 scale: (33-rank)/32 gives 0-1, then scale to 50-95
    normalized_score = 50 + 45*(33-pace_of_play_rank)/32
    score += normalized_score
    score.to_f
  end
  def run_heavy_score
    score = 0
    # Normalize to 50-95 scale: (33-rank)/32 gives 0-1, then scale to 50-95
    normalized_score = 50 + 45*(33-run_heavy_rank)/32
    score += normalized_score
    score.to_f
  end
  def field_goal_score
    score = 0
    # Normalize to 50-95 scale: (33-rank)/32 gives 0-1, then scale to 50-95
    normalized_score = 50 + 45*(33-field_goal_caller_rank)/32
    score += normalized_score
    score.to_f
  end
  # QB
  def qb_score
    score = 0
    score = qb_player.passing_grade_x
    # Return rusher score
    score.to_f
  end
  # RB
  def rushing_score
    score = 0
    # 1st Rusher
    score += 1.0 * rb1_player.rush_grade_x
    # 2nd Rusher
    score += 0.3 * qb_player.rush_grade_x
    # Return rusher score
    score.to_f
  end
  # WR, TE
  def receiver_score
    receiver_score = 0
    recs = top_three_receivers
    # 1st Receiver
    receiver_score += 1.0 * recs.first.receiving_grade_x
    # 2nd Receiver
    receiver_score += 0.7 * recs.second.receiving_grade_x
    # 3rd Receiver
    receiver_score += 0.4 * recs.third.receiving_grade_x
    # Return receiver score
    receiver_score.to_f
  end
  # C, LG, RG, LT, RT
  def pass_block_score
    pass_block_score = 0
    # Tackle importance depends on QB handedness
    unless qb_player&.left_handed
      # For right-handed QB: Left Tackle protects blind side (more important)
      pass_block_score += 1.0 * left_tackle_player.pass_block_grade_x
      pass_block_score += 0.7 * right_guard_player.pass_block_grade_x
      pass_block_score += 0.5 * right_tackle_player.pass_block_grade_x
      pass_block_score += 0.5 * left_guard_player.pass_block_grade_x
    else
      # For left-handed QB: Right Tackle protects blind side (more important)
      pass_block_score += 1.0 * right_tackle_player.pass_block_grade_x
      pass_block_score += 0.7 * left_guard_player.pass_block_grade_x
      pass_block_score += 0.5 * left_tackle_player.pass_block_grade_x
      pass_block_score += 0.5 * right_guard_player.pass_block_grade_x
    end
    # Center
    pass_block_score += 0.5 * center_player.pass_block_grade_x
    # Return pass block score
    pass_block_score.to_f
  end
  # C, LG, RG, LT, RT
  def rush_block_score
    run_block_score = 0
    
    # Center (most important for run blocking - makes calls and anchors the line)
    run_block_score += 1.0 * center_player.run_block_grade_x
    # Left Guard (important for pulling and trap blocks)
    run_block_score += 0.9 * left_guard_player.run_block_grade_x
    # Right Guard (important for pulling and trap blocks)
    run_block_score += 0.9 * right_guard_player.run_block_grade_x
    # Left Tackle (important for sealing the edge)
    run_block_score += 0.8 * left_tackle_player.run_block_grade_x
    # Right Tackle (important for sealing the edge)
    run_block_score += 0.8 * right_tackle_player.run_block_grade_x
    
    # Return run block score
    run_block_score.to_f
  end
  # EDGE, DT, LB
  def pass_rush_score
    pass_rush_score = 0
    # Return pass rush score
    pass_rush_score += 1.0 * pass_rush_players.first.pass_rush_grade_x
    pass_rush_score += 0.7 * pass_rush_players.second.pass_rush_grade_x
    pass_rush_score += 0.4 * pass_rush_players.third.pass_rush_grade_x
    pass_rush_score += 0.4 * pass_rush_players.fourth.pass_rush_grade_x
    pass_rush_score += 0.4 * pass_rush_players.fifth.pass_rush_grade_x
    # Return receiver score
    pass_rush_score.to_f
  end
  # CB, S
  def coverage_score
    coverage_score = 0

    coverage_score = corner_back_players.first.coverage_grade_x
    coverage_score += 0.9 * corner_back_players.second.coverage_grade_x
    coverage_score += 0.7 * corner_back_players.third.coverage_grade_x
    coverage_score += 0.6 * safety_players.first.coverage_grade_x
    coverage_score += 0.6 * safety_players.second.coverage_grade_x
    
    # Return coverage score
    coverage_score.to_f
  end
  # EDGE, DT, LB, CB, S
  def run_defense_score
    run_defense_score = 0

    dinterior_players_sorted = dinterior_players.sort_by { |player| -(player.rush_defense_grade_x || 0) }
    edge_players_sorted = edge_players.sort_by { |player| -(player.rush_defense_grade_x || 0) }
    safety_players_sorted = safety_players.sort_by { |player| -(player.rush_defense_grade_x || 0) }
    corner_back_players_sorted = corner_back_players.sort_by { |player| -(player.rush_defense_grade_x || 0) }

    run_defense_score += 1.0 * linebacker_players.first.rush_defense_grade_x
    run_defense_score += 0.9 * linebacker_players.second.rush_defense_grade_x
    run_defense_score += 0.9 * dinterior_players_sorted.first.rush_defense_grade_x
    run_defense_score += 0.8 * dinterior_players_sorted.second.rush_defense_grade_x
    run_defense_score += 0.7 * dinterior_players_sorted.third.rush_defense_grade_x
    run_defense_score += 0.6 * edge_players_sorted.first.rush_defense_grade_x
    run_defense_score += 0.6 * edge_players_sorted.second.rush_defense_grade_x
    run_defense_score += 0.6 * safety_players_sorted.first.rush_defense_grade_x
    run_defense_score += 0.6 * safety_players_sorted.second.rush_defense_grade_x
    run_defense_score += 0.4 * corner_back_players_sorted.first.rush_defense_grade_x
    run_defense_score += 0.3 * corner_back_players_sorted.second.rush_defense_grade_x
    run_defense_score += 0.2 * corner_back_players_sorted.third.rush_defense_grade_x
    
    # Return run defense score
    run_defense_score.to_f
  end
  def passing_offense_score
    score = 0
    score += 5*offensive_play_caller_score
    score += qb_score**1.6
    score += 4*receiver_score
    score += 2*pass_block_score
    score.to_f
  end
  def rushing_offense_score
    score = 0
    score += 5*rushing_score
    score += 2*rush_block_score
    score.to_f
  end
  def passing_defense_score
    score = 0
    score += 4*pass_rush_score
    score += 3*coverage_score
    score.to_f
  end
  def rushing_defense_score
    score = 0
    score += 3*run_defense_score
    score.to_f
  end
  def defense_score
    score = 0
    score += passing_defense_score
    score += rushing_defense_score
    score.to_f
  end
  def offense_score
    score = 0
    score += passing_offense_score
    score += rushing_offense_score
    score.to_f
  end
  def power_rank_score
    score = 0
    score += offense_score
    score += defense_score
    score.to_f
  end
  # def field_goal_score
  #   score = 0
  #   score += field_goal_rank
  #   score.to_f
  # end
end 