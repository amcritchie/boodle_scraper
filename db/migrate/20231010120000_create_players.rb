class CreatePlayers < ActiveRecord::Migration[6.1]
  def change
    create_table :players do |t|
      t.string  :slug, null: false, unique: true
      t.integer :rank
      t.string  :position
      t.string  :player
      t.string  :first_name
      t.string  :last_name
      t.string  :team_slug
      t.string  :sportsradar_id     # 4254d319-1bc7-4f81-b4ab-b5e6f3402b69
      t.string  :sportsradar_slug   # sr:player:2197894
      t.date    :birth_date
      t.string  :birth_place
      t.string  :high_school
      t.string  :college_conf
      t.integer :rookie_year
      t.string  :status
      t.integer :season_experience
      t.integer :height_inches
      t.float  :weight_pounds

      t.string  :id_sportrac       # spotrac.com/nfl/player/_/id/29036/kyler-murray
      t.string  :slug_sportrac     # spotrac.com/nfl/player/_/id/29036/kyler-murray
      t.string  :slug_pff          # pff.com/player/kyler-murray
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
      t.string  :import_slug
      t.string  :import_from
      t.json    :details
      t.string  :notes
      # PFF General
      t.string  :player_id
      t.string  :team_name
      t.integer :player_game_count, default: 0
      t.string  :franchise_id
      t.integer :declined_penalties
      # PFF Passing
      t.integer :passing_attempts
      t.float   :accuracy_percent
      t.integer :aimed_passes
      t.integer :pass_attempts
      t.float   :avg_time_to_throw
      t.integer :passing_touchdowns
      t.integer :passing_yards
      t.float   :passing_yards_per_attempt
      t.float   :turnover_worthy_plays
      t.float   :turnover_worthy_rate
      t.integer :batted_passes
      t.integer :big_time_throws
      t.float   :btt_rate
      t.float   :completion_percent
      t.integer :completions
      t.integer :def_gen_pressures
      t.float   :drop_rate
      t.integer :dropbacks
      t.integer :drops
      t.integer :first_downs
      t.float   :grades_hands_fumble
      t.float   :grades_offense
      t.float   :grades_pass
      t.float   :grades_run
      t.integer :hit_as_threw
      t.integer :interceptions
      t.integer :passing_snaps
      t.integer :penalties
      t.float   :pressure_to_sack_rate
      t.float   :qb_rating
      t.float   :sack_percent
      t.integer :sacks
      t.integer :scrambles
      t.integer :spikes_thrown
      t.integer :thrown_aways

      # PFF Rushing
      t.integer :rushing_attempts
      t.integer :avoided_tackles
      t.integer :breakaway_attempts
      t.float :breakaway_percent
      t.integer :breakaway_yards
      t.integer :designed_yards
      t.integer :elusive_recv_missed_tackles_forced
      t.integer :elusive_rush_missed_tackles_forced
      t.integer :elu_yco
      t.float :elusive_rating
      t.integer :explosive
      t.integer :fumbles
      t.integer :gap_attempts
      t.float :grades_offense_penalty
      t.float :grades_pass_block
      t.float :grades_pass_route
      t.float :grades_run_block
      t.integer :longest
      t.integer :rec_yards
      t.integer :receptions
      t.integer :routes
      t.integer :run_plays
      t.integer :scramble_yards
      t.integer :targets
      t.integer :total_touches
      t.integer :rushing_touchdowns
      t.integer :rushing_yards
      t.integer :yards_after_contact
      t.float :yards_after_contact_attempt
      t.float :rushing_yards_per_attempt
      t.float :yards_per_route_run
      t.integer :zone_attempts

      # PFF Receiving
      t.float   :avg_depth_of_target
      t.float   :caught_percent
      t.float   :contested_catch_rate
      t.integer :contested_receptions
      t.integer :contested_targets
      t.float   :grades_hands_drop
      t.float   :inline_rate
      t.integer :inline_snaps
      t.float   :pass_block_rate
      t.integer :pass_blocks
      t.integer :pass_plays
      t.float   :route_rate
      t.float   :slot_rate
      t.float   :slot_snaps
      t.float   :targeted_qb_rating
      t.integer :receiving_touchdowns
      t.float   :wide_rate
      t.integer :wide_snaps
      t.integer :receiving_yards
      t.integer :yards_after_catch
      t.integer :yards_after_catch_per_reception
      t.integer :yards_per_reception

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