class CreateGames < ActiveRecord::Migration[7.0]
  def change
    create_table :games do |t|
      t.string    :slug, null: false, unique: true
      t.integer   :season       # 2025
      t.string    :week_slug    # "1"
      t.string    :away_slug    # "buf"
      t.string    :home_slug    # "kc"
      t.string    :title        # "Super Bowl LVII"
      t.string    :sportsradar_id     # 4254d319-1bc7-4f81-b4ab-b5e6f3402b69
      t.string    :sportsradar_slug   # sr:player:2197894
      t.datetime  :scheduled  # "2025-09-08T13:00:00.000Z"
      t.integer :attendance               # 69142
      t.string  :venue_slug   # "glendale_arizona"
      t.string  :status       # "final"
      t.string  :entry_mode                # "closed"
      t.string  :game_type    # "regular"
      t.boolean :conference_game         # true
      t.string  :duration                # "4:25"
      t.float   :away_spread          # -3.5
      t.float   :home_spread          # 3.5
      t.float   :away_implied_total   # 45.5
      t.float   :home_implied_total   # 45.5
      t.float   :away_multiple        # 1.2
      t.float   :home_multiple        # 1.2
      t.float   :over_under           # 50.5
      t.float   :over_under_odds      # 1.91
      t.string  :over_under_result
      t.integer :total_points
      t.integer :away_total
      t.integer :home_total
      t.datetime :kickoff_at
      t.date    :date
      t.string  :start_time
      t.string  :day_of_week
      t.string  :tv_network
      t.boolean :primetime
      t.boolean :overtime
      t.integer :away_team_seed
      t.integer :home_team_seed
      t.string  :winning_team
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
      t.string  :source       # "kaggle","sportsoddshistory","sportsradar"

      t.timestamps
    end

    add_index :games, :source
    add_index :games, :season
    add_index :games, :week_slug
    add_index :games, :away_slug
    add_index :games, :home_slug
    add_index :games, :venue_slug
    add_index :games, :slug, unique: true
    add_index :games, :created_at
    add_index :games, :updated_at
  end
end

# class CreateGames < ActiveRecord::Migration[7.0]
#   def change
#     create_table :games do |t|
#       t.references :week, null: false, foreign_key: true
#       t.references :home_team, null: false, foreign_key: { to_table: :teams }
#       t.references :away_team, null: false, foreign_key: { to_table: :teams }
#       t.references :venue, null: false, foreign_key: true
#       t.datetime :scheduled, null: false
#       t.string :status, null: false
#       t.integer :attendance
#       t.string :entry_mode
#       t.string :sr_id, null: false
#       t.string :game_type, null: false
#       t.boolean :conference_game
#       t.string :duration
#       t.string :title, null: false

#       t.timestamps
#     end

#     add_index :games, :sr_id, unique: true
#   end
# end 