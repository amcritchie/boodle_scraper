# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2025_07_13_235020) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "broadcasts", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.string "network", null: false
    t.string "internet"
    t.string "satellite"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_broadcasts_on_game_id"
  end

  create_table "coaches", force: :cascade do |t|
    t.string "team_slug", null: false
    t.integer "season", null: false
    t.string "sportsradar_id"
    t.string "first_name"
    t.string "last_name"
    t.string "position"
    t.integer "offensive_play_caller_rank"
    t.integer "pace_of_play_rank"
    t.integer "run_heavy_rank"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_coaches_on_created_at"
    t.index ["first_name", "last_name"], name: "index_coaches_on_first_name_and_last_name"
    t.index ["offensive_play_caller_rank"], name: "index_coaches_on_offensive_play_caller_rank"
    t.index ["pace_of_play_rank"], name: "index_coaches_on_pace_of_play_rank"
    t.index ["position"], name: "index_coaches_on_position"
    t.index ["run_heavy_rank"], name: "index_coaches_on_run_heavy_rank"
    t.index ["season"], name: "index_coaches_on_season"
    t.index ["sportsradar_id"], name: "index_coaches_on_sportsradar_id"
    t.index ["team_slug", "season"], name: "index_coaches_on_team_slug_and_season", unique: true
    t.index ["team_slug"], name: "index_coaches_on_team_slug"
    t.index ["updated_at"], name: "index_coaches_on_updated_at"
  end

  create_table "drives", force: :cascade do |t|
    t.string "team_slug", null: false
    t.string "game_slug", null: false
    t.string "sportsradar_id", null: false
    t.string "start_reason", default: "Kickoff"
    t.string "end_reason", default: "End of Game"
    t.integer "play_count", null: false
    t.string "duration", null: false
    t.integer "first_downs", default: 0
    t.integer "gain", default: 0
    t.integer "penalty_yards", default: 0
    t.integer "team_sequence"
    t.string "start_clock"
    t.string "end_clock"
    t.integer "first_drive_yardline"
    t.integer "last_drive_yardline"
    t.integer "farthest_drive_yardline"
    t.integer "net_yards"
    t.integer "pat_points_attempted", default: 0
    t.json "payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sportsradar_id", "team_sequence"], name: "index_drives_on_sportsradar_id_and_team_sequence", unique: true
  end

  create_table "games", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "season"
    t.string "week_slug"
    t.string "away_slug"
    t.string "home_slug"
    t.string "away_score", default: "0"
    t.string "home_score", default: "0"
    t.jsonb "away_scores"
    t.jsonb "home_scores"
    t.string "title"
    t.string "sportsradar_id"
    t.string "sportsradar_slug"
    t.datetime "scheduled"
    t.integer "attendance"
    t.string "venue_slug"
    t.string "status"
    t.string "entry_mode"
    t.string "game_type"
    t.boolean "conference_game"
    t.string "duration"
    t.float "away_spread"
    t.float "home_spread"
    t.float "away_implied_total"
    t.float "home_implied_total"
    t.float "away_multiple"
    t.float "home_multiple"
    t.float "over_under"
    t.float "over_under_odds"
    t.string "over_under_result"
    t.integer "total_points"
    t.integer "away_total"
    t.integer "home_total"
    t.datetime "kickoff_at"
    t.date "date"
    t.string "start_time"
    t.string "day_of_week"
    t.string "tv_network"
    t.boolean "primetime"
    t.boolean "overtime"
    t.integer "away_team_seed"
    t.integer "home_team_seed"
    t.string "winning_team"
    t.integer "away_ot"
    t.integer "home_ot"
    t.integer "away_q4"
    t.integer "home_q4"
    t.integer "away_q3"
    t.integer "home_q3"
    t.integer "away_q2"
    t.integer "home_q2"
    t.integer "away_q1"
    t.integer "home_q1"
    t.string "source"
    t.jsonb "events_array"
    t.jsonb "stangest_events"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "home_passing_touchdowns", default: 0
    t.integer "home_rushing_touchdowns", default: 0
    t.integer "home_field_goals", default: 0
    t.integer "home_extra_points", default: 0
    t.integer "away_passing_touchdowns", default: 0
    t.integer "away_rushing_touchdowns", default: 0
    t.integer "away_field_goals", default: 0
    t.integer "away_extra_points", default: 0
    t.integer "alt_points", default: 0
    t.index ["away_slug"], name: "index_games_on_away_slug"
    t.index ["created_at"], name: "index_games_on_created_at"
    t.index ["home_slug"], name: "index_games_on_home_slug"
    t.index ["season", "week_slug"], name: "index_games_on_season_and_week_slug"
    t.index ["season"], name: "index_games_on_season"
    t.index ["slug"], name: "index_games_on_slug", unique: true
    t.index ["source"], name: "index_games_on_source"
    t.index ["updated_at"], name: "index_games_on_updated_at"
    t.index ["venue_slug"], name: "index_games_on_venue_slug"
    t.index ["week_slug"], name: "index_games_on_week_slug"
  end

  create_table "matchups", force: :cascade do |t|
    t.integer "season"
    t.integer "week_slug"
    t.string "game_slug"
    t.string "team_slug"
    t.string "team_defense_slug"
    t.boolean "home"
    t.boolean "at_home"
    t.integer "rushing_offense_score"
    t.string "rushing_offense_score_string"
    t.integer "rushing_defense_score"
    t.string "rushing_defense_score_string"
    t.integer "passing_offense_score"
    t.string "passing_offense_score_string"
    t.integer "passing_defense_score"
    t.string "passing_defense_score_string"
    t.json "reciever_factors"
    t.integer "pass_block_score"
    t.json "pass_block_factors"
    t.integer "rush_score"
    t.integer "interior_rush_block_score"
    t.integer "exterior_rush_block_score"
    t.integer "interior_rush_defense_score"
    t.integer "exterior_rush_defense_score"
    t.integer "linebacker_rush_defense_score"
    t.integer "safety_rush_defense_score"
    t.integer "corner_rush_defense_score"
    t.integer "passer_score"
    t.integer "reciever_score"
    t.integer "interior_pass_block_score"
    t.integer "exterior_pass_block_score"
    t.integer "interior_rush_score"
    t.integer "exterior_rush_score"
    t.integer "linebacker_coverage_score"
    t.integer "safety_coverage_score"
    t.integer "corner_coverage_score"
    t.integer "sack_score"
    t.json "sack_factors"
    t.integer "coverage_score"
    t.json "coverage_factors"
    t.string "o1"
    t.string "o2"
    t.string "o3"
    t.string "o4"
    t.string "o5"
    t.string "o6"
    t.string "o7"
    t.string "o8"
    t.string "o9"
    t.string "o10"
    t.string "o11"
    t.string "d1"
    t.string "d2"
    t.string "d3"
    t.string "d4"
    t.string "d5"
    t.string "d6"
    t.string "d7"
    t.string "d8"
    t.string "d9"
    t.string "d10"
    t.string "d11"
    t.string "place_kicker"
    t.string "punter"
    t.string "head_coach"
    t.string "offensive_coordinator"
    t.string "defensive_coordinator"
    t.string "special_teams_coordinator"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "periods", force: :cascade do |t|
    t.string "period_type", null: false
    t.integer "number", null: false
    t.integer "sequence", null: false
    t.integer "home_points", default: 0, null: false
    t.integer "away_points", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "player_seasons", force: :cascade do |t|
    t.bigint "player_id", null: false
    t.bigint "season_id", null: false
    t.bigint "team_id"
    t.integer "passing_touchdowns", default: 0
    t.integer "rushing_touchdowns", default: 0
    t.integer "receiving_touchdowns", default: 0
    t.integer "field_goals_made", default: 0
    t.integer "tackles", default: 0
    t.integer "interceptions", default: 0
    t.integer "sacks", default: 0
    t.integer "return_touchdowns", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id", "season_id"], name: "index_player_seasons_on_player_id_and_season_id", unique: true
    t.index ["player_id"], name: "index_player_seasons_on_player_id"
    t.index ["season_id"], name: "index_player_seasons_on_season_id"
    t.index ["team_id"], name: "index_player_seasons_on_team_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "rank"
    t.string "position"
    t.string "player"
    t.string "first_name"
    t.string "last_name"
    t.string "team_slug"
    t.string "sportsradar_id"
    t.string "sportsradar_slug"
    t.date "birth_date"
    t.string "birth_place"
    t.string "high_school"
    t.string "college_conf"
    t.integer "rookie_year"
    t.string "status"
    t.integer "season_experience"
    t.integer "height_inches"
    t.float "weight_pounds"
    t.string "id_sportrac"
    t.string "slug_sportrac"
    t.string "slug_pff"
    t.integer "current_season"
    t.integer "current_base"
    t.integer "current_cap_hit"
    t.integer "jersey"
    t.decimal "offense_grade", precision: 5, scale: 2
    t.decimal "passing_grade", precision: 5, scale: 2
    t.decimal "rushing_grade", precision: 5, scale: 2
    t.decimal "receiving_grade", precision: 5, scale: 2
    t.decimal "run_block_grade", precision: 5, scale: 2
    t.decimal "pass_block_grade", precision: 5, scale: 2
    t.integer "snaps_on_offense"
    t.integer "snaps_passing"
    t.integer "snaps_rushing"
    t.integer "snaps_recieving"
    t.integer "snaps_run_block"
    t.integer "snaps_pass_block"
    t.decimal "defence_grade", precision: 5, scale: 2
    t.decimal "rush_defense_grade", precision: 5, scale: 2
    t.decimal "pass_rush_grade", precision: 5, scale: 2
    t.decimal "coverage_grade", precision: 5, scale: 2
    t.integer "snaps_on_defence"
    t.integer "snaps_rush_defense"
    t.integer "snaps_pass_rush"
    t.integer "snaps_coverage"
    t.decimal "age", precision: 4, scale: 1
    t.string "hand"
    t.string "height"
    t.integer "weight"
    t.decimal "speed", precision: 4, scale: 1
    t.string "college"
    t.integer "draft_year"
    t.integer "draft_round"
    t.integer "draft_pick"
    t.string "import_slug"
    t.string "import_from"
    t.json "details"
    t.string "notes"
    t.string "player_id"
    t.string "team_name"
    t.integer "player_game_count", default: 0
    t.string "franchise_id"
    t.integer "declined_penalties"
    t.integer "passing_attempts"
    t.float "accuracy_percent"
    t.integer "aimed_passes"
    t.integer "pass_attempts"
    t.float "avg_time_to_throw"
    t.integer "passing_touchdowns"
    t.integer "passing_yards"
    t.float "passing_yards_per_attempt"
    t.float "turnover_worthy_plays"
    t.float "turnover_worthy_rate"
    t.integer "batted_passes"
    t.integer "big_time_throws"
    t.float "btt_rate"
    t.float "completion_percent"
    t.integer "completions"
    t.integer "def_gen_pressures"
    t.float "drop_rate"
    t.integer "dropbacks"
    t.integer "drops"
    t.integer "first_downs"
    t.float "grades_hands_fumble"
    t.float "grades_offense"
    t.float "grades_pass"
    t.float "grades_run"
    t.integer "hit_as_threw"
    t.integer "interceptions"
    t.integer "passing_snaps"
    t.integer "penalties"
    t.float "pressure_to_sack_rate"
    t.float "qb_rating"
    t.float "sack_percent"
    t.integer "sacks"
    t.integer "scrambles"
    t.integer "spikes_thrown"
    t.integer "thrown_aways"
    t.integer "rushing_attempts"
    t.integer "avoided_tackles"
    t.integer "breakaway_attempts"
    t.float "breakaway_percent"
    t.integer "breakaway_yards"
    t.integer "designed_yards"
    t.integer "elusive_recv_missed_tackles_forced"
    t.integer "elusive_rush_missed_tackles_forced"
    t.integer "elu_yco"
    t.float "elusive_rating"
    t.integer "explosive"
    t.integer "fumbles"
    t.integer "gap_attempts"
    t.float "grades_offense_penalty"
    t.float "grades_pass_block"
    t.float "grades_pass_route"
    t.float "grades_run_block"
    t.integer "longest"
    t.integer "rec_yards"
    t.integer "receptions"
    t.integer "routes"
    t.integer "run_plays"
    t.integer "scramble_yards"
    t.integer "targets"
    t.integer "total_touches"
    t.integer "rushing_touchdowns"
    t.integer "rushing_yards"
    t.integer "yards_after_contact"
    t.float "yards_after_contact_attempt"
    t.float "rushing_yards_per_attempt"
    t.float "yards_per_route_run"
    t.integer "zone_attempts"
    t.float "avg_depth_of_target"
    t.float "caught_percent"
    t.float "contested_catch_rate"
    t.integer "contested_receptions"
    t.integer "contested_targets"
    t.float "grades_hands_drop"
    t.float "inline_rate"
    t.integer "inline_snaps"
    t.float "pass_block_rate"
    t.integer "pass_blocks"
    t.integer "pass_plays"
    t.float "route_rate"
    t.float "slot_rate"
    t.float "slot_snaps"
    t.float "targeted_qb_rating"
    t.integer "receiving_touchdowns"
    t.float "wide_rate"
    t.integer "wide_snaps"
    t.integer "receiving_yards"
    t.integer "yards_after_catch"
    t.integer "yards_after_catch_per_reception"
    t.integer "yards_per_reception"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "starter", default: false
    t.index ["created_at"], name: "index_players_on_created_at"
    t.index ["first_name"], name: "index_players_on_first_name"
    t.index ["import_slug"], name: "index_players_on_import_slug"
    t.index ["last_name"], name: "index_players_on_last_name"
    t.index ["player"], name: "index_players_on_player"
    t.index ["position"], name: "index_players_on_position"
    t.index ["rank"], name: "index_players_on_rank"
    t.index ["slug"], name: "index_players_on_slug", unique: true
    t.index ["team_slug"], name: "index_players_on_team_slug"
    t.index ["updated_at"], name: "index_players_on_updated_at"
  end

  create_table "plays", force: :cascade do |t|
    t.string "game_slug", null: false
    t.string "week_slug"
    t.string "season_slug"
    t.string "sportsradar_id"
    t.bigint "sport_radar_sequence"
    t.string "event_type"
    t.string "play_type"
    t.string "down"
    t.string "period"
    t.string "category"
    t.text "description"
    t.boolean "turnover", default: false
    t.string "result", default: "strange-play"
    t.string "possession_start_team_slug"
    t.string "possession_end_team_slug"
    t.string "clock_start_time"
    t.string "clock_end_time"
    t.jsonb "score"
    t.jsonb "sport_radar_event"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_type"], name: "index_plays_on_event_type"
    t.index ["game_slug"], name: "index_plays_on_game_slug"
    t.index ["play_type"], name: "index_plays_on_play_type"
    t.index ["result"], name: "index_plays_on_result"
    t.index ["season_slug"], name: "index_plays_on_season_slug"
    t.index ["week_slug"], name: "index_plays_on_week_slug"
  end

  create_table "scores", force: :cascade do |t|
    t.integer "game_id", null: false
    t.integer "player_id", null: false
    t.string "score_type", null: false
    t.string "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "seasons", force: :cascade do |t|
    t.integer "year", null: false
    t.string "season_type", null: false
    t.string "name", null: false
    t.integer "passing_touchdowns", default: 0
    t.integer "rushing_touchdowns", default: 0
    t.integer "field_goals", default: 0
    t.integer "total_touchdowns", default: 0
    t.integer "total_scoring_plays", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["year", "season_type"], name: "index_seasons_on_year_and_season_type", unique: true
  end

  create_table "teams", force: :cascade do |t|
    t.string "slug"
    t.string "slug_long"
    t.string "emoji"
    t.string "name"
    t.string "location"
    t.string "alias"
    t.boolean "active", default: true
    t.string "division"
    t.string "conference"
    t.string "slug_pfr"
    t.string "slug_sportrac"
    t.string "sportsradar_id"
    t.string "slug_sportsradar"
    t.string "conference_pre_2002"
    t.string "division_pre_2002"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_teams_on_active"
    t.index ["alias"], name: "index_teams_on_alias"
    t.index ["created_at"], name: "index_teams_on_created_at"
    t.index ["location"], name: "index_teams_on_location"
    t.index ["name"], name: "index_teams_on_name"
    t.index ["slug"], name: "index_teams_on_slug"
    t.index ["slug_long"], name: "index_teams_on_slug_long"
    t.index ["slug_pfr"], name: "index_teams_on_slug_pfr"
    t.index ["slug_sportrac"], name: "index_teams_on_slug_sportrac"
    t.index ["slug_sportsradar"], name: "index_teams_on_slug_sportsradar"
    t.index ["updated_at"], name: "index_teams_on_updated_at"
  end

  create_table "venues", force: :cascade do |t|
    t.string "name", null: false
    t.string "city", null: false
    t.string "state", null: false
    t.string "country", null: false
    t.string "zip"
    t.string "address"
    t.integer "capacity"
    t.string "surface"
    t.string "roof_type"
    t.string "sr_id", null: false
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sr_id"], name: "index_venues_on_sr_id", unique: true
  end

  create_table "weathers", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.string "condition", null: false
    t.integer "humidity"
    t.integer "temperature", null: false
    t.integer "wind_speed", null: false
    t.string "wind_direction", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_weathers_on_game_id"
  end

  create_table "weeks", force: :cascade do |t|
    t.integer "season_year", null: false
    t.integer "sequence", null: false
    t.string "title"
    t.string "sportsradar_id"
    t.integer "games_count", default: 0
    t.integer "rushing_touchdowns", default: 0
    t.integer "passing_touchdowns", default: 0
    t.integer "defensive_touchdowns", default: 0
    t.integer "special_teams_touchdowns", default: 0
    t.integer "punts", default: 0
    t.integer "kickoffs", default: 0
    t.integer "field_goals", default: 0
    t.integer "extra_points", default: 0
    t.integer "two_point_conversions", default: 0
    t.integer "safeties", default: 0
    t.integer "interceptions", default: 0
    t.integer "fumbles", default: 0
    t.integer "sacks", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "passing_tds_4", default: 0
    t.integer "passing_tds_3", default: 0
    t.integer "passing_tds_2", default: 0
    t.integer "passing_tds_1", default: 0
    t.integer "passing_tds_0", default: 0
    t.integer "rushing_tds_4", default: 0
    t.integer "rushing_tds_3", default: 0
    t.integer "rushing_tds_2", default: 0
    t.integer "rushing_tds_1", default: 0
    t.integer "rushing_tds_0", default: 0
    t.integer "field_goals_5", default: 0
    t.integer "field_goals_4", default: 0
    t.integer "field_goals_3", default: 0
    t.integer "field_goals_2", default: 0
    t.integer "field_goals_1", default: 0
    t.integer "field_goals_0", default: 0
    t.index ["season_year"], name: "index_weeks_on_season_year"
    t.index ["sequence"], name: "index_weeks_on_sequence"
    t.index ["sportsradar_id"], name: "index_weeks_on_sportsradar_id"
  end

  add_foreign_key "broadcasts", "games"
  add_foreign_key "player_seasons", "players"
  add_foreign_key "player_seasons", "seasons"
  add_foreign_key "player_seasons", "teams"
  add_foreign_key "weathers", "games"
end
