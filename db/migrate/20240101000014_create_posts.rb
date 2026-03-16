class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    create_table :posts do |t|
      t.string :title
      t.string :sport
      t.string :stage
      t.integer :impressions
      t.integer :likes
      t.text :content
      t.string :image_url
      t.json :image_proposals
      t.datetime :images_found_at
      t.datetime :image_selected_at
      t.datetime :approved_at
      t.datetime :posted_at
      t.timestamps
    end

    add_index :posts, :stage
  end
end
