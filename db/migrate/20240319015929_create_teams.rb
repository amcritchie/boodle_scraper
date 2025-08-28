class CreateTeams < ActiveRecord::Migration[7.0]
  def change
    create_table :teams do |t|
      t.string :slug                    # ari
      t.string :slug_long               # arizona_cardinals
      t.string :venue_slug              # arizona_cardinals_venue
      t.string :emoji
      t.string :name                    # Arizona Cardinals
      t.string :location                # Arizona
      t.string :alias                   # Cardinals
      t.boolean :active, default: true
      t.string :division
      t.string :conference
      t.string :slug_pfr
      t.string :slug_sportrac           # https://www.spotrac.com/nfl/arizona-cardinals/cap/#
      t.string :sportsradar_id
      t.string :slug_sportsradar        # https://www.spotrac.com/nfl/arizona-cardinals/cap/#
      t.string :conference_pre_2002
      t.string :division_pre_2002

      t.string :color_dark
      t.string :color_accent
      t.string :color_alt1
      t.string :color_alt2
      t.string :color_alt3
      t.string :color_rule

      t.timestamps
    end
    add_index :teams, :slug
    add_index :teams, :slug_long
    add_index :teams, :venue_slug
    add_index :teams, :name
    add_index :teams, :location
    add_index :teams, :alias
    add_index :teams, :active
    add_index :teams, :slug_pfr
    add_index :teams, :slug_sportrac
    add_index :teams, :slug_sportsradar
    add_index :teams, :created_at
    add_index :teams, :updated_at
  end
end
