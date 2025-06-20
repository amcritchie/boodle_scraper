class CreatePeriods < ActiveRecord::Migration[7.0]
  def change
    create_table :periods do |t|
      # t.references :scoring, null: false, foreign_key: true
      t.string :period_type, null: false
      t.integer :number, null: false
      t.integer :sequence, null: false
      t.integer :home_points, null: false, default: 0
      t.integer :away_points, null: false, default: 0

      t.timestamps
    end

    # add_index :periods, [:scoring_id, :sequence], unique: true
  end
end 