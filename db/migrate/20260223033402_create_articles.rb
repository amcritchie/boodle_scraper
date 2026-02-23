class CreateArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :articles do |t|
      t.string :title
      t.string :author
      t.date :published_at
      t.datetime :reviewed_at
      t.string :person_slug
      t.string :main_person_name
      t.json :names
      t.text :disposition
      t.boolean :article_good
      t.boolean :person_identified
      t.boolean :disposition_coherent
      t.text :feedback
      t.string :source
      t.string :source_url
      t.json :source_data_json

      t.timestamps
    end
  end
end
