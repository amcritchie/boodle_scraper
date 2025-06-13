class CreateWeeks < ActiveRecord::Migration[7.0]
  def change
    create_table :weeks do |t|
      t.integer :season_year, null: false
      t.string :sequence, null: false
      t.string :title
      t.string  :sportsradar_id       # 4254d319-1bc7-4f81-b4ab-b5e6f3402b69

      t.timestamps
    end

    add_index :weeks, :season_year
    add_index :weeks, :sequence
  end
end 