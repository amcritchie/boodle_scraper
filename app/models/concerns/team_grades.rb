module TeamGrades
  extend ActiveSupport::Concern

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
    team_rb = starting_rb
    
    # Return the RB's rushing grade, or nil if no RB found
    team_rb&.rushing_grade
  end

  def starting_qb
    # Team RBs
    quarterbacks = players.quarterbacks.offense_grade
    # Return highest offense grade RB
    quarterbacks.first
  end

  def starting_rb
    # Team RBs
    runningbacks = players.running_backs.offense_grade
    # Return highest offense grade RB
    runningbacks.first
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
          grade: qb&.offense_grade,
          passing_grade: qb&.passing_grade,
          rushing_grade: qb&.rushing_grade
        }
      end
      
      # Return sorted by QB grade (highest first)
      qb_grades.sort_by { |_, data| -(data[:passing_grade] || 0) }
    end

    def rush_grades
      # Get all active teams with their starting RB grades
      active_teams = Team.active.includes(:players)
      
      rush_grades = {}
      active_teams.each do |team|
        rb = team.starting_rb
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