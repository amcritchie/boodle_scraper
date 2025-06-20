class CreatePlays < ActiveRecord::Migration[7.0]
  def change
    create_table :plays do |t|
      t.string    :game_slug, null: false
      t.string    :week_slug
      t.string    :season_slug

      t.string    :sportsradar_id
      t.bigint    :sport_radar_sequence # 1736026438391.0
      t.string    :event_type           # play, tv_timeout
      t.string    :play_type            # pass, conversion
      t.string    :down                 # ☝️, ✌️, 🤟, ✊
      t.string    :period               # 1️⃣, 2️⃣, 3️⃣, 4️⃣
      t.string    :category             # pass, rush, kickoff, punt, field_goal, extra_point, two_point_conversion, penalty, fumble, interception, sack, touchdown
      t.text      :description          # L.Jackson pass deep right complete. Catch made by I.Likely for 49 yards. TOUCHDOWN.
      # t.string    :score, default: false
      t.boolean   :turnover, default: false
      t.string    :result, default: 'strange-play'
      
      t.string    :possession_start_team_slug
      t.string    :possession_end_team_slug
      t.string    :clock_start_time
      t.string    :clock_end_time

      t.jsonb     :score
      t.jsonb     :sport_radar_event

      t.timestamps
    end

    # add_index :plays, [:sportsradar_id, :game_slug], unique: true
    add_index :plays, :game_slug
    add_index :plays, :week_slug
    add_index :plays, :season_slug
    add_index :plays, :event_type
    add_index :plays, :play_type
    add_index :plays, :result
  end
end    