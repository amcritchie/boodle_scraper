class CreateMatchups < ActiveRecord::Migration[7.0]
  def change
    create_table :matchups do |t|
      t.integer :season
      t.integer :week
      t.string :game
      t.string :team
      t.boolean :home
      t.boolean :at_home
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
