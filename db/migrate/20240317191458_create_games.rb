class CreateGames < ActiveRecord::Migration[7.0]
  def change
    create_table :games do |t|
      t.string :source
      t.integer :season
      t.string :week
      t.string :away_team
      t.string :home_team
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
      t.boolean :primetime, default: false
      t.boolean :overtime, default: false
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
      t.string :slug, null: false, unique: true

      t.timestamps
    end

    add_index :games, :source
    add_index :games, :season
    add_index :games, :week
    add_index :games, :away_team
    add_index :games, :home_team
    add_index :games, :slug, unique: true
    add_index :games, :created_at
    add_index :games, :updated_at
  end
end
