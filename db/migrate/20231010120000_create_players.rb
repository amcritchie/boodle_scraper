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
      # Add columns from rushing_summary.csv
      t.string :player_id
      t.string :team_name
      t.integer :player_game_count
      t.integer :attempts
      t.integer :avoided_tackles
      t.integer :breakaway_attempts
      t.float :breakaway_percent
      t.integer :breakaway_yards
      t.integer :declined_penalties
      t.integer :designed_yards
      t.integer :drops
      t.integer :elu_recv_mtf
      t.integer :elu_rush_mtf
      t.integer :elu_yco
      t.float :elusive_rating
      t.integer :explosive
      t.integer :first_downs
      t.string :franchise_id
      t.integer :fumbles
      t.integer :gap_attempts
      t.float :grades_hands_fumble
      t.float :grades_offense
      t.float :grades_offense_penalty
      t.float :grades_pass
      t.float :grades_pass_block
      t.float :grades_pass_route
      t.float :grades_run
      t.float :grades_run_block
      t.integer :longest
      t.integer :penalties
      t.integer :rec_yards
      t.integer :receptions
      t.integer :routes
      t.integer :run_plays
      t.integer :scramble_yards
      t.integer :scrambles
      t.integer :targets
      t.integer :total_touches
      t.integer :touchdowns
      t.integer :yards
      t.integer :yards_after_contact
      t.float :yco_attempt
      t.float :ypa
      t.float :yprr
      t.integer :zone_attempts

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