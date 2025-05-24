class CreateTeams < ActiveRecord::Migration[7.0]
  def change
    create_table :teams do |t|
      t.string :slug                    # ari
      t.string :slug_long               # arizona_cardinals
      t.string :emoji
      t.string :name
      t.string :name_short
      t.boolean :active, default: true
      t.string :division
      t.string :conference
      t.string :slug_pfr
      t.string :slug_sportrac             # https://www.spotrac.com/nfl/arizona-cardinals/cap/#
      t.string :conference_pre_2002
      t.string :division_pre_2002

      t.timestamps
    end
    add_index :teams, :slug
    add_index :teams, :slug_long
    add_index :teams, :slug_pfr
    add_index :teams, :slug_sportrac
    add_index :teams, :created_at
    add_index :teams, :updated_at
  end
end
