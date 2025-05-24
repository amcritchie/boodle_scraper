class CreateMatchups < ActiveRecord::Migration[7.0]
  def change
    create_table :matchups do |t|
      t.integer :season
      t.integer :week
      t.string :game_slug
      t.string :home_team_slug
      t.string :away_team_slug

      # Offensive lineup for home team
      t.string :qb
      t.string :rb
      t.string :te
      t.string :wr1
      t.string :wr2
      t.string :flex
      t.string :c
      t.string :g1
      t.string :g2
      t.string :t1
      t.string :t2

      # Defensive lineup for away team
      t.string :de1
      t.string :de2
      t.string :de3
      t.string :lb1
      t.string :lb2
      t.string :db1
      t.string :db2
      t.string :db3
      t.string :db4
      t.string :dflex1
      t.string :dflex2

      t.timestamps
    end
    add_index :matchups, :season
    add_index :matchups, :week
    add_index :matchups, :game_slug
    add_index :matchups, :home_team_slug
    add_index :matchups, :away_team_slug
    add_index :matchups, :created_at
    add_index :matchups, :updated_at
  end
end
