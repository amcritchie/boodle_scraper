class CreateMatchups < ActiveRecord::Migration[7.0]
  def change
    create_table :matchups do |t|
      t.integer :season
      t.integer :week
      t.string :game
      t.string :team_slug
      t.string :team_defense_slug
      t.boolean :home
      t.boolean :at_home
      t.integer :rushing_offense_score
      t.string :rushing_offense_score_string
      t.integer :rushing_defense_score
      t.string :rushing_defense_score_string
      t.integer :passing_offense_score
      t.string :passing_offense_score_string
      t.integer :passing_defense_score
      t.string :passing_defense_score_string


      
      # t.integer :reciever_score
      t.json :reciever_factors
      t.integer :pass_block_score
      t.json :pass_block_factors

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

      # Offensive players
      t.string :o1
      t.string :o2
      t.string :o3
      t.string :o4
      t.string :o5
      t.string :o6
      t.string :o7
      t.string :o8
      t.string :o9
      t.string :o10
      t.string :o11

      # Defensive players
      t.string :d1
      t.string :d2
      t.string :d3
      t.string :d4
      t.string :d5
      t.string :d6
      t.string :d7
      t.string :d8
      t.string :d9
      t.string :d10
      t.string :d11

      # Coaches and special teams
      t.string :place_kicker
      t.string :punter
      t.string :head_coach
      t.string :offensive_coordinator
      t.string :defensive_coordinator
      t.string :special_teams_coordinator

      t.timestamps
    end
  end
end
