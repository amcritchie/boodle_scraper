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

ActiveRecord::Schema[7.0].define(version: 2025_03_19_015931) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "contracts", force: :cascade do |t|
    t.string "player_slug"
    t.integer "current_season"
    t.integer "current_base"
    t.integer "current_cap_hit"
    t.integer "term_contract"
    t.integer "term_years"
    t.integer "average_salary"
    t.integer "signing_bonus"
    t.integer "total_gaurentied"
    t.string "free_agent"
    t.string "url"
    t.json "year1"
    t.json "year2"
    t.json "year3"
    t.json "year4"
    t.json "year5"
    t.json "year6"
    t.json "year7"
    t.json "year8"
    t.json "year9"
    t.json "year10"
    t.json "year11"
    t.json "year12"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["average_salary"], name: "index_contracts_on_average_salary"
    t.index ["created_at"], name: "index_contracts_on_created_at"
    t.index ["current_base"], name: "index_contracts_on_current_base"
    t.index ["current_cap_hit"], name: "index_contracts_on_current_cap_hit"
    t.index ["current_season"], name: "index_contracts_on_current_season"
    t.index ["player_slug"], name: "index_contracts_on_player_slug"
    t.index ["signing_bonus"], name: "index_contracts_on_signing_bonus"
    t.index ["term_years"], name: "index_contracts_on_term_years"
    t.index ["total_gaurentied"], name: "index_contracts_on_total_gaurentied"
    t.index ["updated_at"], name: "index_contracts_on_updated_at"
  end

  create_table "games", force: :cascade do |t|
    t.string "source"
    t.integer "season"
    t.string "week"
    t.string "away_team"
    t.string "home_team"
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
    t.boolean "primetime", default: false
    t.boolean "overtime", default: false
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
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["away_team"], name: "index_games_on_away_team"
    t.index ["created_at"], name: "index_games_on_created_at"
    t.index ["home_team"], name: "index_games_on_home_team"
    t.index ["season"], name: "index_games_on_season"
    t.index ["slug"], name: "index_games_on_slug", unique: true
    t.index ["source"], name: "index_games_on_source"
    t.index ["updated_at"], name: "index_games_on_updated_at"
    t.index ["week"], name: "index_games_on_week"
  end

  create_table "matchups", force: :cascade do |t|
    t.integer "season"
    t.integer "week"
    t.string "game"
    t.string "team"
    t.boolean "home"
    t.boolean "at_home"
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

  create_table "players", force: :cascade do |t|
    t.integer "rank"
    t.string "position"
    t.string "player"
    t.string "first_name"
    t.string "last_name"
    t.string "team_slug"
    t.string "id_sportrac"
    t.string "slug_sportrac"
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
    t.string "slug", null: false
    t.string "import_slug"
    t.string "import_from"
    t.json "details"
    t.string "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "teams", force: :cascade do |t|
    t.string "slug"
    t.string "slug_long"
    t.string "emoji"
    t.string "name"
    t.string "name_short"
    t.boolean "active", default: true
    t.string "division"
    t.string "conference"
    t.string "slug_pfr"
    t.string "slug_sportrac"
    t.string "conference_pre_2002"
    t.string "division_pre_2002"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_teams_on_created_at"
    t.index ["slug"], name: "index_teams_on_slug"
    t.index ["slug_long"], name: "index_teams_on_slug_long"
    t.index ["slug_pfr"], name: "index_teams_on_slug_pfr"
    t.index ["slug_sportrac"], name: "index_teams_on_slug_sportrac"
    t.index ["updated_at"], name: "index_teams_on_updated_at"
  end

end
