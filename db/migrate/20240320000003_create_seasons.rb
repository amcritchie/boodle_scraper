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
  end
end 