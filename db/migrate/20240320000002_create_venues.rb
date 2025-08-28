class CreateVenues < ActiveRecord::Migration[7.0]
  def change
    create_table :venues do |t|
      t.string :slug, null: false
      t.string :name
      t.string :city
      t.string :state
      t.string :country
      t.string :zip
      t.string :address
      t.integer :capacity
      t.string :surface
      t.string :roof_type
      t.boolean :true_home
      t.string :sr_id, null: false
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6

      t.timestamps
    end

    add_index :venues, :sr_id, unique: true
    add_index :venues, :slug, unique: true
  end
end 