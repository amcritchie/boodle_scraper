class CreateTeamsSeasons < ActiveRecord::Migration[7.0]
  def change
    create_table :teams_seasons do |t|
      t.string :team_slug
      t.integer :season_year
      t.string :o1
      t.string :o2
      t.string :o3
      t.string :o4
      t.string :o5
      t.string :o6
      t.string :o7
      t.string :o8
      t.string :o9
      t.string :o10
      t.string :o11
      t.string :d1
      t.string :d2
      t.string :d3
      t.string :d4
      t.string :d5
      t.string :d6
      t.string :d7
      t.string :d8
      t.string :d9
      t.string :d10
      t.string :d11
      t.string :hc
      t.string :oc
      t.string :dc
      t.string :offensive_play_caller
      t.string :defensive_play_caller
      t.timestamps
    end
  end
end
