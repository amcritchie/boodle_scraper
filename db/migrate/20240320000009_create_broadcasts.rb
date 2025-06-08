class CreateBroadcasts < ActiveRecord::Migration[7.0]
  def change
    create_table :broadcasts do |t|
      t.references :game, null: false, foreign_key: true
      t.string :network, null: false
      t.string :internet
      t.string :satellite

      t.timestamps
    end
  end
end 