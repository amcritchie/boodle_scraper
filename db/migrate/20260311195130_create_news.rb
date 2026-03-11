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

      t.timestamps
    end

    add_index :news, :stage
  end
end
