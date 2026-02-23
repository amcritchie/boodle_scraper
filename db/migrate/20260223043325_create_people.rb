class CreatePeople < ActiveRecord::Migration[7.0]
  def change
    create_table :people do |t|
      t.string  :first_name
      t.string  :last_name
      t.string  :slug
      t.string  :celebrity_type
      t.string  :player_slug
      t.date    :birthday
      t.string  :twitter_account
      t.string  :twitter_hashtag
      t.string  :last_image_used

      t.timestamps
    end
  end
end
