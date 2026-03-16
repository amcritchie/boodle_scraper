class CreateGames < ActiveRecord::Migration[7.0]
  def change
    create_table :games do |t|
      t.string :slug, null: false
      t.integer :season
      t.string :week_slug
      t.string :away_slug
      t.string :home_slug
      t.string :away_score, default: "0"
      t.string :home_score, default: "0"
      t.jsonb :away_scores
      t.jsonb :home_scores
      t.string :title
      t.string :sportsradar_id
      t.string :sportsradar_slug
      t.datetime :scheduled
      t.integer :attendance
      t.string :venue_slug
      t.string :status
      t.string :entry_mode
      t.string :game_type
      t.boolean :conference_game
      t.string :duration
      t.float :away_spread
      t.float :home_spread
      t.float :away_implied_total
      t.float :home_implied_total
      t.float :away_multiple
      t.float :home_multiple
      t.float :over_under
      t.float :over_under_odds
      t.string :over_under_result
      t.integer :total_points
      t.integer :away_total
      t.integer :home_total
      t.datetime :kickoff_at
      t.date :date
      t.string :start_time
      t.string :day_of_week
      t.string :tv_network
      t.boolean :primetime
      t.boolean :overtime
      t.integer :away_team_seed
      t.integer :home_team_seed
      t.string :winning_team
      t.integer :away_ot
      t.integer :home_ot
      t.integer :away_q4
      t.integer :home_q4
      t.integer :away_q3
      t.integer :home_q3
      t.integer :away_q2
      t.integer :home_q2
      t.integer :away_q1
      t.integer :home_q1
      t.string :source
      t.jsonb :events_array
      t.jsonb :strangest_events
      t.integer :home_passing_touchdowns, default: 0
      t.integer :home_rushing_touchdowns, default: 0
      t.integer :home_field_goals, default: 0
      t.integer :home_extra_points, default: 0
      t.integer :away_passing_touchdowns, default: 0
      t.integer :away_rushing_touchdowns, default: 0
      t.integer :away_field_goals, default: 0
      t.integer :away_extra_points, default: 0
      t.integer :alt_points, default: 0
      t.string :favorite
      t.float :favorite_spread
      t.float :team_total
      t.timestamps
    end

    add_index :games, :slug, unique: true
    add_index :games, :season
    add_index :games, :week_slug
    add_index :games, [:season, :week_slug]
    add_index :games, :away_slug
    add_index :games, :home_slug
    add_index :games, :venue_slug
    add_index :games, :source
    add_index :games, :created_at
    add_index :games, :updated_at

    create_table :broadcasts do |t|
      t.bigint :game_id, null: false
      t.string :network, null: false
      t.string :internet
      t.string :satellite
      t.timestamps
    end

    add_index :broadcasts, :game_id
    add_foreign_key :broadcasts, :games

    create_table :weathers do |t|
      t.bigint :game_id, null: false
      t.string :condition, null: false
      t.integer :humidity
      t.integer :temperature, null: false
      t.integer :wind_speed, null: false
      t.string :wind_direction, null: false
      t.timestamps
    end

    add_index :weathers, :game_id
    add_foreign_key :weathers, :games

    create_table :scores do |t|
      t.integer :game_id, null: false
      t.integer :player_id, null: false
      t.string :score_type, null: false
      t.string :description, null: false
      t.timestamps
    end

    add_index :scores, :game_id
    add_index :scores, :player_id

    create_table :periods do |t|
      t.string :period_type, null: false
      t.integer :number, null: false
      t.integer :sequence, null: false
      t.integer :home_points, default: 0, null: false
      t.integer :away_points, default: 0, null: false
      t.timestamps
    end
  end
end
