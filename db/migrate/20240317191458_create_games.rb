class CreateGames < ActiveRecord::Migration[7.0]
  def change
    create_table :games do |t|
      t.string :source
      t.integer :season
      t.string :week
      t.string :away_team
      t.string :home_team
      t.string :winning_team
      t.integer :away_total
      t.integer :home_total
      t.boolean :primetime, default: false
      t.boolean :overtime, default: false
      t.string :day_of_week
      t.string :start_time
      t.date :date
      t.integer :total_points
      t.float :over_under
      t.float :over_under_odds
      t.float :away_spread
      t.float :home_spread
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
      t.float :odds

      t.timestamps
    end
  end
end
