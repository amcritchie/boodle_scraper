class CreateDrivesAndPlays < ActiveRecord::Migration[7.0]
  def change
    create_table :drives do |t|
      t.string :team_slug, null: false
      t.string :game_slug, null: false
      t.string :sportsradar_id, null: false
      t.string :start_reason, default: "Kickoff"
      t.string :end_reason, default: "End of Game"
      t.integer :play_count, null: false
      t.string :duration, null: false
      t.integer :first_downs, default: 0
      t.integer :gain, default: 0
      t.integer :penalty_yards, default: 0
      t.integer :team_sequence
      t.string :start_clock
      t.string :end_clock
      t.integer :first_drive_yardline
      t.integer :last_drive_yardline
      t.integer :farthest_drive_yardline
      t.integer :net_yards
      t.integer :pat_points_attempted, default: 0
      t.json :payload
      t.timestamps
    end

    add_index :drives, [:sportsradar_id, :team_sequence], unique: true

    create_table :plays do |t|
      t.string :game_slug, null: false
      t.string :week_slug
      t.string :season_slug
      t.string :sportsradar_id
      t.bigint :sport_radar_sequence
      t.string :event_type
      t.string :play_type
      t.string :down
      t.string :period
      t.string :category
      t.text :description
      t.boolean :turnover, default: false
      t.string :result, default: "strange-play"
      t.string :possession_start_team_slug
      t.string :possession_end_team_slug
      t.string :clock_start_time
      t.string :clock_end_time
      t.jsonb :score
      t.jsonb :sport_radar_event
      t.timestamps
    end

    add_index :plays, :game_slug
    add_index :plays, :week_slug
    add_index :plays, :season_slug
    add_index :plays, :event_type
    add_index :plays, :play_type
    add_index :plays, :result
  end
end
