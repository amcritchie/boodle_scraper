class CreateTeamsWeeks < ActiveRecord::Migration[7.0]
  def change
    create_table :teams_weeks do |t|
      t.string :team_slug
      t.integer :season_year
      t.integer :week_number
      # Offensive players
      t.string :qb
      t.string :rb1
      t.string :rb2
      t.string :wr1
      t.string :wr2
      t.string :wr3
      t.string :te
      t.string :c
      t.string :lt
      t.string :rt
      t.string :lg
      t.string :rg
      # Defensive players
      t.string :eg1
      t.string :eg2
      t.string :dl1
      t.string :dl2
      t.string :dl3
      t.string :lb1
      t.string :lb2
      t.string :cb1
      t.string :cb2
      t.string :cb3
      t.string :s1
      t.string :s2
      # Coaches and special teams
      t.string :place_kicker
      t.string :punter
      t.string :head_coach
      t.string :offensive_play_caller
      t.string :defensive_play_caller
      t.string :offensive_coordinator
      t.string :defensive_coordinator
      t.string :special_teams_coordinator
      # Offensive and defensive rankings
      t.integer :power_rank
      t.integer :offense_rank
      t.integer :defense_rank
      t.integer :passing_offense_rank
      t.integer :passing_defense_rank
      t.integer :rushing_offense_rank
      t.integer :rushing_defense_rank
      t.integer :field_goal_rank

      t.integer :offensive_play_caller_rank
      t.integer :defensive_play_caller_rank
      t.integer :qb_passing_rank
      t.integer :pass_block_rank
      t.integer :receiver_core_rank
      t.integer :pass_rush_rank
      t.integer :coverage_rank
      t.integer :rushing_rank
      t.integer :rush_block_rank
      t.integer :run_defense_rank
      t.integer :pace_of_play_rank
      t.integer :run_heavy_rank

      t.integer :qb_score
      t.integer :rushing_score
      t.integer :receiver_score
      t.integer :pass_block_score
      t.integer :rush_block_score
      t.integer :pass_rush_score
      t.integer :coverage_score
      t.integer :run_defense_score

      t.integer :passing_offense_score
      t.integer :rushing_offense_score
      t.integer :offense_score

      t.integer :passing_defense_score
      t.integer :rushing_defense_score
      t.integer :defense_score

      t.integer :power_rank_score
      t.integer :field_goal_score
      
      # Additional scoring fields
      t.float :offensive_play_caller_score
      t.float :defensive_play_caller_score
      t.float :pace_of_play_score
      t.float :run_heavy_score
      
      t.timestamps
    end
  end
end
