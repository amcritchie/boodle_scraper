class CreateDrives < ActiveRecord::Migration[7.0]
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
      # Payload
      t.json :payload

      t.timestamps
    end

    add_index :drives, [:sportsradar_id, :team_sequence], unique: true
  end
end 