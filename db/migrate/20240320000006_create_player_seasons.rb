class CreatePlayerSeasons < ActiveRecord::Migration[7.0]
  def change
    create_table :player_seasons do |t|
      t.references :player, null: false, foreign_key: true
      t.references :season, null: false, foreign_key: true
      t.references :team, foreign_key: true
      t.integer :passing_touchdowns, default: 0
      t.integer :rushing_touchdowns, default: 0
      t.integer :receiving_touchdowns, default: 0
      t.integer :field_goals_made, default: 0
      t.integer :tackles, default: 0
      t.integer :interceptions, default: 0
      t.integer :sacks, default: 0
      t.integer :return_touchdowns, default: 0

      t.timestamps
    end

    add_index :player_seasons, [:player_id, :season_id], unique: true
  end
end 