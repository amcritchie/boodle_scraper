class CreatePlayers < ActiveRecord::Migration[6.1]
  def change
    create_table :players do |t|
      t.string :slug, null: false, unique: true
      t.integer :rank
      t.string :position
      t.string :player
      t.string :first_name
      t.string :last_name
      t.string :team_slug
      t.string :id_sportrac       # spotrac.com/nfl/player/_/id/29036/kyler-murray
      t.string :slug_sportrac     # spotrac.com/nfl/player/_/id/29036/kyler-murray
      t.integer :current_season
      t.integer :current_base
      t.integer :current_cap_hit
      t.integer :jersey
      # Offensive Players
      t.decimal :offense_grade,     precision: 5, scale: 2
      t.decimal :passing_grade,     precision: 5, scale: 2
      t.decimal :rushing_grade,     precision: 5, scale: 2
      t.decimal :receiving_grade,   precision: 5, scale: 2
      t.decimal :run_block_grade,   precision: 5, scale: 2
      t.decimal :pass_block_grade,  precision: 5, scale: 2
      t.integer :snaps_on_offense
      t.integer :snaps_passing
      t.integer :snaps_rushing
      t.integer :snaps_recieving
      t.integer :snaps_run_block
      t.integer :snaps_pass_block
      # Defensive Players
      t.decimal :defence_grade,       precision: 5, scale: 2
      t.decimal :rush_defense_grade,  precision: 5, scale: 2
      t.decimal :pass_rush_grade,     precision: 5, scale: 2
      t.decimal :coverage_grade,      precision: 5, scale: 2
      t.integer :snaps_on_defence
      t.integer :snaps_rush_defense
      t.integer :snaps_pass_rush
      t.integer :snaps_coverage
      # Attributes
      t.decimal :age, precision: 4, scale: 1
      t.string :hand
      t.string :height
      t.integer :weight
      t.decimal :speed, precision: 4, scale: 1
      t.string :college
      t.integer :draft_year
      t.integer :draft_round
      t.integer :draft_pick
      # Extra data
      t.string :import_slug
      t.string :import_from
      t.json :details
      t.string :notes

      t.timestamps
    end

    add_index :players, :rank
    add_index :players, :player
    add_index :players, :position
    add_index :players, :team_slug
    add_index :players, :first_name
    add_index :players, :last_name
    add_index :players, :slug, unique: true
    add_index :players, :import_slug
    add_index :players, :created_at
    add_index :players, :updated_at
  end
end