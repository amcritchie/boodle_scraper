class CreateScorings < ActiveRecord::Migration[7.0]
  def change
    create_table :scorings do |t|
      t.references :game, null: false, foreign_key: true
      t.integer :home_points, null: false, default: 0
      t.integer :away_points, null: false, default: 0

      t.timestamps
    end
  end
end 