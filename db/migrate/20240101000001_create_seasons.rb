class CreateSeasons < ActiveRecord::Migration[7.0]
  def change
    create_table :seasons do |t|
      t.integer :year, null: false
      t.string :season_type, null: false
      t.string :name, null: false
      t.integer :passing_touchdowns, default: 0
      t.integer :rushing_touchdowns, default: 0
      t.integer :field_goals, default: 0
      t.integer :total_touchdowns, default: 0
      t.integer :total_scoring_plays, default: 0
      t.timestamps
    end

    add_index :seasons, [:year, :season_type], unique: true

    create_table :weeks do |t|
      t.integer :season_year, null: false
      t.integer :sequence, null: false
      t.string :title
      t.string :sportsradar_id
      t.integer :games_count, default: 0
      t.integer :rushing_touchdowns, default: 0
      t.integer :passing_touchdowns, default: 0
      t.integer :defensive_touchdowns, default: 0
      t.integer :special_teams_touchdowns, default: 0
      t.integer :punts, default: 0
      t.integer :kickoffs, default: 0
      t.integer :field_goals, default: 0
      t.integer :extra_points, default: 0
      t.integer :two_point_conversions, default: 0
      t.integer :safeties, default: 0
      t.integer :interceptions, default: 0
      t.integer :fumbles, default: 0
      t.integer :sacks, default: 0
      t.integer :passing_tds_4, default: 0
      t.integer :passing_tds_3, default: 0
      t.integer :passing_tds_2, default: 0
      t.integer :passing_tds_1, default: 0
      t.integer :passing_tds_0, default: 0
      t.integer :rushing_tds_4, default: 0
      t.integer :rushing_tds_3, default: 0
      t.integer :rushing_tds_2, default: 0
      t.integer :rushing_tds_1, default: 0
      t.integer :rushing_tds_0, default: 0
      t.integer :field_goals_5, default: 0
      t.integer :field_goals_4, default: 0
      t.integer :field_goals_3, default: 0
      t.integer :field_goals_2, default: 0
      t.integer :field_goals_1, default: 0
      t.integer :field_goals_0, default: 0
      t.timestamps
    end

    add_index :weeks, :season_year
    add_index :weeks, :sequence
    add_index :weeks, :sportsradar_id
  end
end
