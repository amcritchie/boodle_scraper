class CreateCoaches < ActiveRecord::Migration[6.1]
  def change
    create_table :coaches do |t|
      t.string :slug, null: false
      t.string :team_slug, null: false
      t.integer :season, null: false
      t.string :sportsradar_id
      t.string :first_name
      t.string :last_name
      t.string :position
      t.integer :offensive_play_caller_rank
      t.integer :defensive_play_caller_rank
      t.integer :pace_of_play_rank
      t.integer :field_goal_rank
      t.integer :run_heavy_rank      
      
      t.timestamps
    end

    add_index :coaches, :team_slug
    add_index :coaches, :season
    add_index :coaches, :slug
    # add_index :coaches, [:team_slug, :season], unique: true
    add_index :coaches, :sportsradar_id
    add_index :coaches, :position
    add_index :coaches, :offensive_play_caller_rank
    add_index :coaches, :pace_of_play_rank
    add_index :coaches, :run_heavy_rank
    add_index :coaches, [:first_name, :last_name]
    add_index :coaches, :created_at
    add_index :coaches, :updated_at
  end
end 