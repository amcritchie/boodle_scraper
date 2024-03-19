class CreateTeams < ActiveRecord::Migration[7.0]
  def change
    create_table :teams do |t|
      t.string :slug
      t.boolean :active, default: true
      t.string :division
      t.string :conference
      t.string :name
      t.string :name_short
      t.string :slug_pfr
      t.string :conference_pre_2002
      t.string :division_pre_2002

      t.timestamps
    end
  end
end
