class CreateTeamsSeasons < ActiveRecord::Migration[7.0]
  def change
    create_table :teams_seasons do |t|
      t.string :team_slug
      t.integer :season_year

      t.string :qb
      t.string :rb1
      t.string :rb2
      t.string :wr1
      t.string :wr2
      t.string :wr3
      t.string :te
      t.string :c
      t.string :lt
      t.string :rt
      t.string :lg
      t.string :rg

      t.string :eg1
      t.string :eg2
      t.string :dl1
      t.string :dl2
      t.string :dl3
      t.string :lb1
      t.string :lb2
      t.string :cb1
      t.string :cb2
      t.string :cb3
      t.string :s1
      t.string :s2

      t.string :place_kicker
      t.string :punter

      t.string :hc
      t.string :oc
      t.string :dc
      t.string :offensive_play_caller
      t.string :defensive_play_caller
      t.timestamps
    end
  end
end
