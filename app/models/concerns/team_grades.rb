module TeamGrades
  extend ActiveSupport::Concern

  def offensive_play_caller_coach
    coaches.where.not(offensive_play_caller_rank: nil).order(:offensive_play_caller_rank).first
  end

  def defensive_play_caller_coach
    coaches.where.not(defensive_play_caller_rank: nil).order(:defensive_play_caller_rank).first
  end

  def starting_qb
    # First try to find a designated starter
    starter_qb = players.quarterbacks.first
    return starter_qb if starter_qb.present?
    
    # Fallback to highest offense grade QB if no starter is designated
    quarterbacks = players.quarterbacks.offense_grade
    quarterbacks.first
  end
  def starting_rbs
    # Team RBs
    running_backs = players.running_backs.offense_grade
    # Return highest offense grade RB
    running_backs.limit(2)
  end
  def starting_wrs
    # Team WRs
    wide_receivers = players.wide_receivers.offense_grade
    # Return highest offense graded WRs
    wide_receivers.limit(3)
  end
  def starting_te
    # Team TEs
    tight_ends = players.tight_ends.offense_grade
    # Return highest offense grade TE
    tight_ends.first
  end
  # def starting_flex_offense
  #   # Team Flex
  #   flex = players.flex.offense_grade.where.not(id: ([starting_rbs&.id] + starting_wrs.map(&:id) + [starting_te&.id]))
  #   # Return highest offense grade Flex
  #   flex.first
  # end
  def starting_oline
    # Get all oline players ordered by offense grade
    oline_players = players.oline.offense_grade.to_a
    
    # Get the top 5 players
    top_5 = oline_players.first(5)
    
        # Check if there's a center in the top 5
    has_center_in_top_5 = top_5.any? { |player| player.position == 'center' }
    
    # Count centers in top 5
    centers_in_top_5 = top_5.count { |player| player.position == 'center' }
    
    # Fix for Tampa Bay Oline Starters
    # If no center in top 5, check 6th and 7th players for a center
    if !has_center_in_top_5 && oline_players.length >= 6
      # Look for a center in positions 6 and 7
      [5, 6].each do |index|
        next if index >= oline_players.length
        
        player = oline_players[index]
        
        if player.position == 'center'
          # Swap this center with the 5th player
          top_5[4] = player
          break
        end
      end
    end
    
    # Cheifs have two centers in top 5
    # If there are 2 centers in top 5, replace the lower-graded center with next best guard/tackle
    if centers_in_top_5 >= 2 && oline_players.length >= 6
      # Find the centers in top 5 and their grades
      centers_with_grades = top_5.each_with_index.select { |player, _| player.position == 'center' }
                                 .map { |player, index| { player: player, index: index, grade: player.grades_offense || 0 } }
      
      # Sort by grade to find the lower-graded center
      centers_with_grades.sort_by! { |center| center[:grade] }
      lower_center = centers_with_grades.first
      
      # Find the next best guard or tackle (position 6 onwards)
      replacement_player = nil
      (5...oline_players.length).each do |index|
        player = oline_players[index]
        if player.position == 'guard' || player.position == 'tackle'
          replacement_player = player
          break
        end
      end
      
      # Replace the lower-graded center with the replacement player
      if replacement_player
        top_5[lower_center[:index]] = replacement_player
      end
    end
    
    # Return the modified top 5
    Player.where(id: top_5.map(&:id))
  end
  def starting_center
    # Team Center
    center = players.center.offense_grade
    # Return highest offense grade Center
    center.first
  end
  def starting_guards
    # Team Guards
    guards = players.guards.offense_grade
    # Return highest offense grade Guards
    guards.limit(2)
  end
  def starting_tackles
    # Team Tackles  
    tackles = players.tackles.offense_grade
    # Return highest offense grade Tackles
    tackles.limit(2)
  end

  def starting_defensive_ends
    # Team Defensive Ends
    defensive_ends = players.defensive_ends.defence_grade
    # Return highest defense grade Defensive Ends
    defensive_ends.limit(2)
  end

  def starting_edge_rushers
    # Team Edge Rushers
    edge_rushers = players.edge_rushers.defence_grade
    # Return highest defense grade Edge Rushers
    edge_rushers.limit(2)
  end

  def starting_linebackers
    # Team Linebackers
    linebackers = players.linebackers.defence_grade
    # Return highest defense grade Linebackers
    linebackers.limit(2)
  end

  def starting_safeties
    # Team Safeties
    safeties = players.safeties.defence_grade
    # Return highest defense grade Safeties
    safeties.limit(2)
  end

  def starting_cornerbacks
    # Team Cornerbacks
    cornerbacks = players.cornerbacks.defence_grade
    # Return highest defense grade Cornerbacks
    cornerbacks.limit(3)
  end

  def starting_flex_dline
    # Team Flex Defense
    flex = players.flex_dline.defence_grade.where.not(id: (starting_defensive_ends.map(&:id) + starting_edge_rushers.map(&:id) + starting_linebackers.map(&:id) + starting_safeties.map(&:id) + starting_cornerbacks.map(&:id)))
    # Return highest defense grade Flex Defense
    flex.first
  end

  def qb_passing_grade
    # Get this team's starting QB
    team_qb = starting_qb
    # Return the QB's passing grade, or nil if no QB found
    team_qb&.passing_grade
  end

  def qb_rushing_grade
    # Get this team's starting QB
    team_qb = starting_qb
    
    # Return the QB's rushing grade, or nil if no QB found
    team_qb&.rushing_grade
  end

  def rush_grade
    # Get this team's starting RB
    team_rb = starting_rbs.first
    
    # Return the RB's rushing grade, or nil if no RB found
    team_rb&.rushing_grade
  end

  class_methods do
    def qb_pass_grades
      # Get all active teams with their starting QB grades
      active_teams = Team.active.includes(:players)
      
      qb_grades = {}
      active_teams.each do |team|
        qb = team.starting_qb
        qb_grades[team.slug] = {
          team_name: team.name,
          qb: qb&.player,
          grade: qb&.grades_offense || 60,
          grades_pass: qb&.grades_pass || 60,
          grades_run: qb&.grades_run || 60
        }
      end
      
      # Return sorted by QB grade (highest first)
      qb_grades.sort_by { |_, data| -(data[:grades_pass] || 0) }
    end

    def oline_pass_block_grades
      # Get all active teams with their starting offensive line pass block grades
      active_teams = Team.active.includes(:players)
      
      oline_grades = {}
      # grades_pass_block_total = 0
      active_teams.each do |team|
        # Get starting offensive line (best 5 linemen regardless of position)
        oline_players = team.starting_oline
        grades_pass_block_total = oline_players.sum { |player| player.grades_pass_block || 60 }
        grades_run_block_total  = oline_players.sum { |player| player.grades_run_block || 60 }
        
        if oline_players.any?
          avg_pass_block_grade = oline_players.sum { |player| player.grades_pass_block || 60 } / oline_players.size.to_f
        else
          avg_pass_block_grade = 60 # Default grade if no offensive line players found
        end
        
        pass_block_total = 0
        run_block_total = 0

        oline_grades[team.slug] = {
          team_name: team.name,
          oline_players: oline_players.map { |player| 
            pass_block_grade = player.grades_pass_block || 60 
            pass_block_grade = 60 if pass_block_grade.to_i < 1
            run_block_grade = player.grades_run_block || 60 
            run_block_grade = 60 if run_block_grade.to_i < 1
            pass_block_total += pass_block_grade
            run_block_total += run_block_grade
            { 
              slug: player.slug,
              pass_block_grade: pass_block_grade,
              run_block_grade: run_block_grade
            }},
          avg_pass_block_grade: pass_block_total/5,
          avg_run_block_grade: run_block_total/5,
          grades_pass_block_total: grades_pass_block_total,
          grades_pass_block_total_s: "#{oline_players.map { |player| player.grades_pass_block }.join(", ")}",
          grades_run_block_total: pass_block_total
        }
      end

      ap oline_grades
      
      # Return sorted by average pass block grade (highest first)
      oline_grades.sort_by { |_, data| -(data[:avg_pass_block_grade] || 0) }
    end

    def rush_grades
      # Get all active teams with their starting RB grades
      active_teams = Team.active.includes(:players)
      
      rush_grades = {}
      active_teams.each do |team|
        rb = team.starting_rbs.first
        rush_grades[team.slug] = {
          team_name: team.name,
          rb_name: rb&.player,
          rb_grade: rb&.offense_grade,
          rb_rushing_grade: rb&.rushing_grade,
          rb_receiving_grade: rb&.receiving_grade
        }
      end
      
      # Return sorted by RB rushing grade (highest first)
      rush_grades.sort_by { |_, data| -(data[:rb_rushing_grade] || 0) }
    end
  end
end 