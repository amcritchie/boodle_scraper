class CreatePeople < ActiveRecord::Migration[7.0]
  def change
    create_table :people do |t|
      t.string :first_name
      t.string :last_name
      t.string :slug
      t.string :player_slug
      t.date :birthday
      t.string :twitter_account
      t.string :twitter_hashtag
      t.timestamps
    end

    add_index :people, :slug
  end
end
