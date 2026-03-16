class CreateMemes < ActiveRecord::Migration[7.0]
  def change
    create_table :memes do |t|
      t.string :path
      t.string :feeling
      t.jsonb :feeling_array
      t.string :team_slug
      t.string :player_slug
      t.datetime :last_used_at
      t.integer :rank
      t.timestamps
    end

    add_index :memes, :feeling
    add_index :memes, :team_slug
  end
end
