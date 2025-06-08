class CreateWeathers < ActiveRecord::Migration[7.0]
  def change
    create_table :weathers do |t|
      t.references :game, null: false, foreign_key: true
      t.string :condition, null: false
      t.integer :humidity
      t.integer :temperature, null: false
      t.integer :wind_speed, null: false
      t.string :wind_direction, null: false

      t.timestamps
    end
  end
end 