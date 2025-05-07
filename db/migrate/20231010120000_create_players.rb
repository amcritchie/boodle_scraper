class CreatePlayers < ActiveRecord::Migration[6.1]
  def change
    create_table :players do |t|
      t.integer :rank
      t.string :position
      t.string :player
      t.string :first_name
      t.string :last_name
      t.string :team
      t.integer :jersey
      t.decimal :overall_grade, precision: 5, scale: 2
      t.decimal :passing_grade, precision: 5, scale: 2
      t.decimal :running_grade, precision: 5, scale: 2
      t.decimal :rpo_grade, precision: 5, scale: 2
      t.decimal :dropback_grade, precision: 5, scale: 2
      t.decimal :pocket_grade, precision: 5, scale: 2
      t.integer :total_snaps
      t.integer :pass_snaps
      t.integer :rush_snaps
      t.integer :rpo_snaps
      t.integer :dropback_snaps
      t.integer :pocket_snaps
      t.decimal :age, precision: 4, scale: 1
      t.string :hand
      t.string :height
      t.integer :weight
      t.decimal :speed, precision: 4, scale: 1
      t.string :college
      t.integer :draft_year
      t.integer :draft_round
      t.integer :draft_pick
      t.string :slug, null: false, unique: true
      
      t.string :import_slug
      t.string :import_from
      t.json :details
      t.string :notes

      t.timestamps
    end

    add_index :players, :team
    add_index :players, :player
    add_index :players, :position
    add_index :players, :slug, unique: true
    add_index :players, :import_slug
    add_index :players, :created_at
    add_index :players, :updated_at
  end
end
