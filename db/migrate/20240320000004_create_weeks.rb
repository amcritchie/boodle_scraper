class CreateWeeks < ActiveRecord::Migration[7.0]
  def change
    create_table :weeks do |t|
      t.references :season, null: false, foreign_key: true
      t.integer :sequence, null: false
      t.string :title, null: false

      t.timestamps
    end

    add_index :weeks, [:season_id, :sequence], unique: true
  end
end 