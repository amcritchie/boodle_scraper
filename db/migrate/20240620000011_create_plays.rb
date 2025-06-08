class CreatePlays < ActiveRecord::Migration[7.0]
  def change
    create_table :plays do |t|
      t.string :team_slug, null: false
      t.string :game_slug, null: false
      t.string :sportsradar_id, null: false
      t.string :clock
      t.integer :home_points
      t.integer :away_points
      t.string :play_type     # pass, conversion
      t.datetime :wall_clock
      t.text :description
      t.boolean :official, default: false
      t.boolean :scoring_play, default: false
      t.string :score_type, default: false
      t.string :score_points, default: false

      t.timestamps
    end

    add_index :plays, [:sportsradar_id, :game_slug], unique: true
  end
end 