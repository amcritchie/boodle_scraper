class CreateWeeks < ActiveRecord::Migration[7.0]
  def change
    create_table :weeks do |t|
      t.integer :season_year, null: false
      t.integer :sequence, null: false
      t.string :title
      t.string  :sportsradar_id       # 4254d319-1bc7-4f81-b4ab-b5e6f3402b69

      t.integer :games_count,               default: 0
      t.integer :rushing_touchdowns,        default: 0
      t.integer :passing_touchdowns,        default: 0 # 6pt
      t.integer :defensive_touchdowns,      default: 0 # 6pt
      t.integer :special_teams_touchdowns,  default: 0 # 6pt
      t.integer :punts,                     default: 0 # 1pt (kickoff)
      t.integer :kickoffs,                  default: 0 # 1pt (punt)
      t.integer :field_goals,               default: 0 # 3pt
      t.integer :extra_points,              default: 0 # 1pt
      t.integer :two_point_conversions,     default: 0 # 2pt
      t.integer :interceptions,             default: 0 # 1pt
      t.integer :fumbles,                   default: 0 # 1pt
      t.integer :sacks,                     default: 0 # 1pt

      t.timestamps
    end

    add_index :weeks, :season_year
    add_index :weeks, :sequence
    add_index :weeks, :sportsradar_id
  end
end 