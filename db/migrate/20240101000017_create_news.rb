class CreateNews < ActiveRecord::Migration[7.0]
  def change
    create_table :news do |t|
      t.string :stage, default: "new", null: false
      t.string :url
      t.string :author
      t.datetime :published_at
      t.string :primary_person
      t.string :primary_person_slug
      t.string :primary_team
      t.string :primary_team_slug
      t.string :title
      t.string :title_short
      t.text :summary
      t.text :opinion
      t.jsonb :post_body
      t.jsonb :image_options
      t.string :selected_image
      t.string :feeling
      t.string :feeling_emoji
      t.string :what_happened
      t.string :x_post_id
      t.string :x_post_url
      t.integer :rank
      t.string :hashtag
      t.string :content_type, default: "x_post"
      t.integer :meme_id
      t.string :discord_message_id
      t.string :video_path
      t.timestamps
    end

    add_index :news, :stage
    add_index :news, :rank
    add_index :news, :x_post_id, unique: true, where: "(x_post_id IS NOT NULL)"
    add_index :news, :content_type
    add_index :news, :primary_person_slug
    add_index :news, :primary_team_slug
  end
end
