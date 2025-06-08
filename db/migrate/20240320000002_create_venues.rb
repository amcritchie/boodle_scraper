class CreateVenues < ActiveRecord::Migration[7.0]
  def change
    create_table :venues do |t|
      t.string :name, null: false
      t.string :city, null: false
      t.string :state, null: false
      t.string :country, null: false
      t.string :zip
      t.string :address
      t.integer :capacity
      t.string :surface
      t.string :roof_type
      t.string :sr_id, null: false
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6

      t.timestamps
    end

    add_index :venues, :sr_id, unique: true
  end
end 