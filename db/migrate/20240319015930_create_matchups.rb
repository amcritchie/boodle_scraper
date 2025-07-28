class CreateMatchups < ActiveRecord::Migration[7.0]
  def change
    create_table :matchups do |t|
      t.integer :season
      t.integer :week_slug
      t.string :game_slug
      t.string :team_slug
      t.string :team_defense_slug
      t.boolean :home

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
      t.integer :offensive_play_caller_rank
      t.integer :pace_of_play_rank
      t.integer :run_heavy_rank
      t.integer :qb_passing_rank
      t.integer :receiver_core_rank
      t.integer :pass_block_rank
      t.integer :pass_rush_rank
      t.integer :coverage_rank
      t.integer :rushing_rank
      t.integer :rush_block_rank
      t.integer :run_defense_rank

      t.integer :field_goal_score
      t.integer :rushing_offense_score
      t.integer :rushing_defense_score
      t.integer :passing_offense_score
      t.integer :passing_defense_score
      t.integer :passing_attack_score
      t.integer :rushing_attack_score
      t.string :rushing_offense_score_string
      t.string :rushing_defense_score_string
      t.string :passing_offense_score_string
      t.string :passing_defense_score_string

      t.integer :passing_attack_rank
      t.integer :rushing_attack_rank
      t.integer :field_goal_rank

      t.integer :passing_td_points
      t.integer :rushing_td_points
      t.integer :field_goal_points
      
      # t.integer :reciever_score
      t.json :reciever_factors
      t.integer :pass_block_score
      t.json :pass_block_factors

      t.integer :rush_score
      t.integer :interior_rush_block_score
      t.integer :exterior_rush_block_score
      t.integer :interior_rush_defense_score
      t.integer :exterior_rush_defense_score
      t.integer :linebacker_rush_defense_score
      t.integer :safety_rush_defense_score
      t.integer :corner_rush_defense_score
      # t.integer :safety_coverage_score
      # t.integer :corner_coverage_score

      t.integer :passer_score
      t.integer :reciever_score
      t.integer :interior_pass_block_score
      t.integer :exterior_pass_block_score
      t.integer :interior_rush_score
      t.integer :exterior_rush_score
      t.integer :linebacker_coverage_score
      t.integer :safety_coverage_score
      t.integer :corner_coverage_score

      t.integer :sack_score
      t.json :sack_factors
      t.integer :coverage_score
      t.json :coverage_factors
    #   t.references :team, foreign_key: true

      t.timestamps
    end
  end
end
