module PredictionConcern
  extend ActiveSupport::Concern

  # Yards per carry
  def calculate_prediction_yards_per_carry(offense_teams_season, defense_teams_season)
    # Pull relevant ranks
    rushing_score     = (33 - offense_teams_season.rushing_rank)                / 32.0
    oline_score       = (33 - offense_teams_season.oline_run_block_rank)        / 32.0
    play_caller_score = (33 - offense_teams_season.offensive_play_caller_rank)  / 32.0
    run_defense_score = (33 - defense_teams_season.run_defense_rank)            / 32.0
    # -1.5 ... 1
    trench_matchup = (oline_score - (1.5*run_defense_score))
    # 3.1 ... 5.5
    yards_per_carry = 4.3 + (0.8*trench_matchup) + (0.25*rushing_score)  + (0.15*play_caller_score)  # 0.35*(oline_score - run_defense_score)+ 0.15*(rushing_score - run_defense_score)
    # Update the matchup
    update(prediction_yards_per_carry: yards_per_carry)
  end
  # Carry Attempts
  def calculate_prediction_carry_attempts(offense_teams_season, defense_teams_season)
    spread = self.spread || 0
    # spread -6 | +3 more carries | 
    game_script_score = -0.5*spread
    play_caller_score = (33 - offense_teams_season.offensive_play_caller_rank)  / 32.0
    coverage_score    = (33 - defense_teams_season.coverage_rank)  / 32.0

    # Calculate carry attempts (base 25 carries, adjusted by play calling, rushing ability, pace, and run tendency)
    carry_attempts = 26 + (0.4*play_caller_score) + (0.35*game_script_score) + (0.15*coverage_score)
    # Update the matchup
    update(prediction_carry_attempts: carry_attempts.round)
  end

  # Rushing Yards
  def calculate_prediction_rushing_yards(offense_teams_season, defense_teams_season)
    # Update the matchup
    update(prediction_rushing_yards: prediction_carry_attempts*prediction_yards_per_carry)
  end

  # Pocket Time
  def calculate_prediction_seconds_until_pressure(offense_teams_season, defense_teams_season)
    # Pull relevant ranks


    qb_score            = (33 - offense_teams_season.qb_passing_rank)               / 32.0
    oline_score         = (33 - offense_teams_season.oline_pass_block_rank)         / 32.0
    play_caller_score   = (33 - offense_teams_season.offensive_play_caller_rank)    / 32.0
    pass_rush_score     = (33 - defense_teams_season.pass_rush_rank)                / 32.0




    # play_caller_rank  = (offense_teams_season.offensive_play_caller_rank || 16)
    # qb_rank           = (offense_teams_season.qb_passing_rank || 16)
    # oline_rank        = (offense_teams_season.oline_pass_block_rank || 16)
    # pass_rush_rank    = (defense_teams_season.pass_rush_rank || 16)

    # play_caller_score = (33 - play_caller_rank) / 32.0
    # qb_score          = (33 - qb_rank) / 32.0
    # oline_score       = (33 - oline_rank) / 32.0
    # pass_rush_score   = (33 - pass_rush_rank) / 32.0


    # -1.5 ... 1
    trench_matchup = (oline_score - (1.5*pass_rush_score))
    # Calculate pocket time
    pocket_time = 2.5 + (0.5*trench_matchup) + (0.2*qb_score) + (0.2*play_caller_score)
    # Update the matchup
    update(prediction_seconds_until_pressure: pocket_time)
  end

  def pocket_score
    case prediction_seconds_until_pressure
    when 0...2.3    then -1.0
    when 2.3...2.5  then -0.5
    when 2.5...2.7  then  0.0
    when 2.7...2.9  then  0.5
    else                  1.0
    end
  end

  def run_threat_score
    case prediction_yards_per_carry
    when 0...3.4    then -1.0
    when 3.4...3.8  then -0.5
    when 3.8...4.6  then  0.0
    when 4.6...5.0  then  0.5
    else                  1.0
    end
  end



  def calculate_prediction_yards_per_attempt(offense_teams_season, defense_teams_season)
    # Pull relevant ranks

    qb_score            = (33 - offense_teams_season.qb_passing_rank)               / 32.0
    receiver_score      = (33 - offense_teams_season.receiver_core_rank)            / 32.0
    play_caller_score   = (33 - offense_teams_season.offensive_play_caller_rank)    / 32.0
    coverage_score      = (33 - defense_teams_season.coverage_rank)                 / 32.0

    prediction_seconds_until_pressure
    prediction_yards_per_carry



    receiver_matchup    = (33 - offense_teams_season.receiver_core_rank)  / 32.0

    # -1 ... 1
    receiver_matchup = receiver_score - coverage_score

    # # -1 ... 1
    # pocket_score = (2.0 * (prediction_seconds_until_pressure - 2.6)).clamp(-1.0, 1.0)


    yards_per_attempt = 7.1 + (0.7*pocket_score) + (0.6*receiver_matchup) + (0.5*qb_score) + (0.3*run_threat_score) + (0.2*play_caller_score)


    # # -2 ... 2
    # pocket_score = pocket_score + receiver_matchup






    # play_caller_rank  = (offense_teams_season.offensive_play_caller_rank || 16)
    # qb_rank           = (offense_teams_season.qb_passing_rank || 16)
    # receiver_rank     = (offense_teams_season.receiver_core_rank || 16)
    # coverage_rank     = (defense_teams_season.coverage_rank || 16)

    # play_caller_score = (33 - play_caller_rank) / 32.0
    # qb_score          = (33 - qb_rank) / 32.0
    # receiver_score    = (33 - receiver_rank) / 32.0
    # coverage_score    = (33 - coverage_rank) / 32.0

    # puts "================================="
    # puts "Matchup #{team.name} vs #{team_defense.name}"
    # puts "play_caller_score:      🧠 #{play_caller_score}"
    # puts "qb_score:               🏈 #{qb_score}"
    # puts "receiver_score:            🏠 #{receiver_score}"
    # puts "coverage_score:        💨 #{coverage_score}"
    # puts "================================="
    # # Calculate pass yards
    # yards_per_attempt = 7.1 + (0.5*qb_score) + (0.45*receiver_score) + (0.2*play_caller_score) - (0.55*coverage_score) + (0.35*(receiver_score-coverage_score))
    # Update the matchup
    update(prediction_yards_per_attempt: yards_per_attempt)
  end

  def calculate_prediction_passing_attempts(offense_teams_season, defense_teams_season)
    # Pull relevant ranks
    play_caller_rank  = (offense_teams_season.offensive_play_caller_rank || 16)
    qb_rank           = (offense_teams_season.qb_passing_rank || 16)
    # pace_of_play_rank = (offense_teams_season.pace_of_play_rank || 16)
    # run_heavy_rank    = (offense_teams_season.run_heavy_rank || 16)
    coverage_rank     = (defense_teams_season.coverage_rank || 16)

    play_caller_score = (33 - play_caller_rank) / 32.0
    qb_score        = (33 - qb_rank) / 32.0
    # run_heavy_score   = (33 - run_heavy_rank) / 32.0
    coverage_score    = (33 - coverage_rank) / 32.0

    # Calculate passing attempts (base 35 attempts, adjusted by play calling, pace, and coverage)
    pass_attempts = 34 + (4*play_caller_score) + (2*qb_score) - (2*coverage_score)
    # Update the matchup
    update(prediction_passing_attempts: pass_attempts.round)
  end

  def calculate_prediction_passing_yards(offense_teams_season, defense_teams_season)
    # Update the matchup
    update(prediction_passing_yards: prediction_passing_attempts*prediction_yards_per_attempt)
  end

  def calculate_passing_offense_score(offense_teams_season)
    play_caller_rank  = (offense_teams_season.offensive_play_caller_rank || 16)
    qb_rank           = (offense_teams_season.qb_passing_rank || 16)
    receiver_rank     = (offense_teams_season.receiver_core_rank || 16)
    oline_rank        = (offense_teams_season.oline_pass_block_rank || 16)
    # Convert rankings to scores (1-32 scale, where 1 is best)
    # Higher score = better passing offense
    play_caller_score = (33 - play_caller_rank) / 32.0 * 100
    qb_score          = (33 - qb_rank) / 32.0 * 100
    receiver_score    = (33 - receiver_rank) / 32.0 * 100
    oline_score       = (33 - oline_rank) / 32.0 * 100
    # Weighted composite score
    passing_offense_score = (play_caller_score * 0.3 + qb_score * 0.5 + receiver_score * 0.2 + oline_score * 0.2).to_i
    passing_attack_rank   = (33 - passing_offense_score) / 32.0 * 100
    # Create score string
    passing_offense_score_string = "PC-#{play_caller_rank}|QB-#{qb_rank}|REC-#{receiver_rank}|OL-#{oline_rank}"
    # Update the matchup
    update(
      passing_offense_score: passing_offense_score,
      passing_offense_score_string: passing_offense_score_string
    )
  end

  def calculate_rushing_offense_score(offense_teams_season)
    play_caller_rank  = (offense_teams_season.offensive_play_caller_rank || 16)
    rushing_rank      = (offense_teams_season.rushing_rank || 16)
    oline_rank        = (offense_teams_season.oline_run_block_rank || 16)
    # Convert rankings to scores (1-32 scale, where 1 is best)
    # Higher score = better rushing offense
    play_caller_score = (33 - play_caller_rank) / 32.0 * 100
    rushing_score = (33 - rushing_rank) / 32.0 * 100
    oline_run_block_score = (33 - oline_rank) / 32.0 * 100
    # Weighted composite score
    rushing_offense_score = (play_caller_score * 0.3 + rushing_score * 0.4 + oline_run_block_score * 0.3).to_i
    # Create score string
    rushing_offense_score_string = "PC-#{play_caller_rank}|RUSH-#{rushing_rank}|OL-#{oline_rank}"
    # Update the matchup
    update(
      rushing_offense_score: rushing_offense_score,
      rushing_offense_score_string: rushing_offense_score_string
    )
  end

  def calculate_rushing_defense_score(defense_teams_season)
    run_defense_rank  =  (defense_teams_season.run_defense_rank || 16)
    # Convert rankings to scores (1-32 scale, where 1 is best)
    # Higher score = better rushing defense
    run_defense_score = (33 - run_defense_rank) / 32.0 * 100
    # For rushing defense, we'll use the run defense rank as the primary metric
    rushing_defense_score = run_defense_score.to_i
    # Create score string
    rushing_defense_score_string = "RD-#{run_defense_rank}"    
    # Update the matchup
    update(
      rushing_defense_score: rushing_defense_score,
      rushing_defense_score_string: rushing_defense_score_string
    )
  end

  def calculate_passing_defense_score(defense_teams_season)
    pass_rush_rank    = (defense_teams_season.pass_rush_rank || 16)
    coverage_rank     = (defense_teams_season.coverage_rank || 16)
    # Convert rankings to scores (1-32 scale, where 1 is best)
    # Higher score = better passing defense
    pass_rush_score   = (33 - pass_rush_rank) / 32.0 * 100
    coverage_score    = (33 - coverage_rank) / 32.0 * 100
    # Weighted composite score
    passing_defense_score = (pass_rush_score * 0.4 + coverage_score * 0.6).to_i
    # Create score string
    passing_defense_score_string = "PR-#{pass_rush_rank}|COV-#{coverage_rank}"
    # Update the matchup
    update(
      passing_defense_score: passing_defense_score,
      passing_defense_score_string: passing_defense_score_string
    )
  end

  def calculate_passing_attack_score(offense_teams_season, defense_teams_season)
    play_caller_rank  = (offense_teams_season.offensive_play_caller_rank || 16)
    qb_rank           = (offense_teams_season.qb_passing_rank || 16)
    receiver_rank     = (offense_teams_season.receiver_core_rank || 16)
    oline_rank        = (offense_teams_season.oline_pass_block_rank || 16)
    pass_rush_rank    = (defense_teams_season.pass_rush_rank || 16)
    coverage_rank     = (defense_teams_season.coverage_rank || 16)
    pace_of_play_rank = (offense_teams_season.pace_of_play_rank || 16)
    run_heavy_rank    = (offense_teams_season.run_heavy_rank || 16)
    # Convert rankings to scores (1-32 scale, where 1 is best)
    # Higher score = better passing attack
    play_caller_score = (33 - play_caller_rank) / 32.0 * 100
    qb_score          = (33 - qb_rank) / 32.0 * 100
    receiver_score    = (33 - receiver_rank) / 32.0 * 100
    oline_score       = (33 - oline_rank) / 32.0 * 100
    pass_rush_score   = (33 - pass_rush_rank) / 32.0 * 100
    coverage_score    = (33 - coverage_rank) / 32.0 * 100
    pace_score        = (33 - pace_of_play_rank) / 32.0 * 100
    run_heavy_score   = (33 - run_heavy_rank) / 32.0 * 100
    # Todo add in QB inteligence
    # -100 to 100
    pocket_score = oline_score - (pass_rush_score * 0.5)
    # Coverage Advantage Score
    # -100 to 300
    passing_score = qb_score * 1.5 + receiver_score * 1.5 - (coverage_score * 0.5)
    # Final Passing Matchup Score with pace and run_heavy adjustments
    # -250 to 600 | 200 + 150 + 300 | 0 + -150 + -100
    passing_matchup_score = play_caller_score * 2 + pocket_score * 1.5 + passing_score * 1.0 + pace_score * 0.5 - run_heavy_score * 0.3
    puts "================================="
    puts "Matchup #{team.name} vs #{team_defense.name}"
    puts "passing_matchup_score:  🏈 #{passing_matchup_score}"
    puts "---------------------------------"
    puts "play_caller_score:      🧠 #{play_caller_score}"
    puts "passing_score:          🤲 #{passing_score}"
    puts "pocket_score:           🛡️  #{pocket_score}"
    puts "pace_score:             ⏱️  #{pace_score}"
    puts "run_heavy_score:        👟 #{run_heavy_score}"
    puts "---------------------------------"
    puts "play_caller_score:      🧠 #{play_caller_score}"
    puts "qb_score:               🏈 #{qb_score}"
    puts "receiver_score:         🤲 #{receiver_score}"
    puts "coverage_score:         👁️  #{coverage_score}"
    puts "oline_score:            🏠 #{oline_score}"
    puts "pass_rush_score:        💨 #{pass_rush_score}"
    puts "================================="
    # Update the matchup
    # update(passing_attack_score: passing_matchup_score.to_i)
    update(passing_attack_score: prediction_passing_yards.to_i)
  end

  def calculate_rushing_attack_score(offense_teams_season, defense_teams_season)
    play_caller_rank  = (offense_teams_season.offensive_play_caller_rank || 16)
    rushing_rank      = (offense_teams_season.rushing_rank || 16)
    oline_rank        = (offense_teams_season.oline_run_block_rank || 16)
    run_defense_rank  = (defense_teams_season.run_defense_rank || 16)
    pace_of_play_rank = (offense_teams_season.pace_of_play_rank || 16)
    run_heavy_rank    = (offense_teams_season.run_heavy_rank || 16)
    # Convert rankings to scores (1-32 scale, where 1 is best)
    # Higher score = better rushing attack
    play_caller_score = (33 - play_caller_rank) / 32.0 * 100
    rushing_score     = (33 - rushing_rank) / 32.0 * 100
    oline_score       = (33 - oline_rank) / 32.0 * 100
    run_defense_score = (33 - run_defense_rank) / 32.0 * 100
    pace_score        = (33 - pace_of_play_rank) / 32.0 * 100
    run_heavy_score   = (33 - run_heavy_rank) / 32.0 * 100
    # Weighted composite score for rushing attack with pace and run_heavy adjustments
    # -150 to 470 | 150 + 200 + 120 - 0 | 0 + 0 + 0 -150
    rushing_attack_score = play_caller_score * 1.5 + rushing_score * 2.0 + oline_score * 1.2 - run_defense_score * 1.0 + pace_score * 0.3 + run_heavy_score * 0.5

        # Reduce field goal score based on offensive attack scores
    # Teams with high rushing/passing attack scores score more TDs, so fewer FGs
    # rushing_attack_reduction = (rushing_attack_score || 0) * 0.2  # Reduce by 30% of rushing attack score
    passing_attack_reduction = (passing_attack_score || 0) * 0.2  # Reduce by 20% of passing attack score
    
    # Apply reductions (ensure field goal score doesn't go below 0)
    rushing_attack_score_after_reductions = [rushing_attack_score - passing_attack_reduction, 0].max


    puts "================================="
    puts "Matchup #{team.name} #{team.emoji} vs #{team_defense.name} #{team_defense.emoji}"
    puts "rushing_attack_score:   👟 #{rushing_attack_score}"
    puts "rushing_attack_score_after_reductions:   👟 #{rushing_attack_score_after_reductions}"
    puts "---------------------------------"
    puts "play_caller_score:      🧠 #{play_caller_score}"
    puts "rushing_score:          👟 #{rushing_score}"
    puts "oline_score:            🏠 #{oline_score}"
    puts "run_defense_score:      🛑 #{run_defense_score}"
    puts "pace_score:             ⏱️  #{pace_score}"
    puts "run_heavy_score:        👟 #{run_heavy_score}"
    # Update the matchup
    update(rushing_attack_score: prediction_rushing_yards.to_i)
  end

  def calculate_field_goal_score(offense_teams_season, defense_teams_season)
    field_goal_rank   = (offense_teams_season.offensive_play_caller_coach.field_goal_rank || 16)
    pace_of_play_rank = (offense_teams_season.pace_of_play_rank || 16)
    run_heavy_rank    = (offense_teams_season.run_heavy_rank || 16)
    
    # Convert rankings to scores (1-32 scale, where 1 is best)
    # Higher score = better field goal opportunities
    field_goal_score  = (33 - field_goal_rank) / 32.0 * 100
    pace_score        = (33 - pace_of_play_rank) / 32.0 * 100
    run_heavy_score   = (33 - run_heavy_rank) / 32.0 * 100
  
    # Weighted composite score for field goal attack with pace and run_heavy adjustments
    # 0 to 300 | 100 + 100 + 100 | 0 + 0 + 0
    field_goal_score = field_goal_score * 1.0 + pace_score * 0.8 - run_heavy_score * 0.2
    
    # Reduce field goal score based on offensive attack scores
    # Teams with high rushing/passing attack scores score more TDs, so fewer FGs
    rushing_attack_reduction = (rushing_attack_score || 0) * 0.2  # Reduce by 30% of rushing attack score
    passing_attack_reduction = (passing_attack_score || 0) * 0.1  # Reduce by 20% of passing attack score
    
    # Apply reductions (ensure field goal score doesn't go below 0)
    field_goal_score_after_reductions = [field_goal_score - rushing_attack_reduction - passing_attack_reduction, 0].max
    
    # puts "================================="
    # puts "Matchup #{team.name} vs #{team_defense.name}"
    # puts "field_goal_score_after_reductions: 🥅 #{field_goal_score_after_reductions}"
    # puts "---------------------------------"
    # puts "field_goal_score:        🥅 #{field_goal_score}"
    # puts "pace_score:              ⏱️  #{pace_score}"
    # puts "run_heavy_score:         👟 #{run_heavy_score}"
    # puts "rushing_attack_reduction:👟 #{rushing_attack_score} | #{rushing_attack_reduction}"
    # puts "passing_attack_reduction:🏈 #{passing_attack_score} | #{passing_attack_reduction}"
    # puts "================================="
    
    # Update the matchup
    update(field_goal_score: field_goal_score_after_reductions.to_i)
  end
end
