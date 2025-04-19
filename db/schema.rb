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

ActiveRecord::Schema[7.0].define(version: 2024_03_19_015929) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.float "over_under"
    t.float "over_under_odds"
    t.string "over_under_result"
    t.integer "total_points"
    t.integer "away_total"
    t.integer "home_total"
    t.date "date"
    t.string "start_time"
    t.string "day_of_week"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "teams", force: :cascade do |t|
    t.string "slug"
    t.boolean "active", default: true
    t.string "division"
    t.string "conference"
    t.string "name"
    t.string "name_short"
    t.string "slug_pfr"
    t.string "conference_pre_2002"
    t.string "division_pre_2002"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
