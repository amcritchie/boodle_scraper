class CreateScorings < ActiveRecord::Migration[7.0]
  def change
    create_table :scores do |t|
      t.integer :game_id, null: false
      t.integer :player_id, null: false
      t.string :score_type, null: false
      t.string :description, null: false

      t.timestamps
    end
  end
end 