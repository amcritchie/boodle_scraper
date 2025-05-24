class CreatePlayers < ActiveRecord::Migration[6.1]
  def change
    create_table :players do |t|
      t.integer :rank
      t.string :position
      t.string :player
      t.string :first_name
      t.string :last_name
      t.string :team_slug
      t.integer :jersey
      # QB
      t.decimal :overall_grade,   precision: 5, scale: 2
      t.decimal :passing_grade,   precision: 5, scale: 2
      t.decimal :running_grade,   precision: 5, scale: 2
      t.decimal :rpo_grade,       precision: 5, scale: 2
      t.decimal :dropback_grade,  precision: 5, scale: 2
      t.decimal :pocket_grade,    precision: 5, scale: 2
      # RB, WR, TE
      t.decimal :receiving_grade,    precision: 5, scale: 2
      t.decimal :rushing_grade,      precision: 5, scale: 2
      t.decimal :yac_grade,          precision: 5, scale: 2
      t.decimal :route_grade,        precision: 5, scale: 2
      t.integer :intermediate_yards
      t.integer :deep_yards
      t.integer :screen_yards
      t.integer :total_yards
      t.integer :rush_yards
      t.integer :receiving_yards
      t.integer :missed_tackles_forced
      t.integer :td
      t.integer :first_downs
      # Blocking
      t.decimal :pass_block_grade,   precision: 5, scale: 2
      t.decimal :run_block_grade,    precision: 5, scale: 2
      t.decimal :screen_block_grade, precision: 5, scale: 2
      # DE, Edge, LB, Safty, CB
      t.decimal :coverage_grade,     precision: 5, scale: 2
      t.decimal :run_defense_grade,  precision: 5, scale: 2
      t.decimal :tackling_grade,     precision: 5, scale: 2
      t.decimal :pass_rush_grade,    precision: 5, scale: 2
      # Attributes
      t.integer :snaps
      t.integer :run_snaps
      t.integer :pass_rush_snaps
      t.integer :coverage_snaps
      t.integer :passing_snaps
      t.integer :routes
      t.integer :qb_hits
      t.integer :total_snaps
      t.integer :pass_snaps
      t.integer :rush_snaps
      t.integer :rpo_snaps
      t.integer :dropback_snaps
      t.integer :pocket_snaps
      t.integer :run_block_snaps
      t.integer :pass_block_snaps
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
      t.string :slug, null: false, unique: true
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