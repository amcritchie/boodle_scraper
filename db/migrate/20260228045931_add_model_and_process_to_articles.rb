class AddModelAndProcessToArticles < ActiveRecord::Migration[7.0]
  def change
    add_column :articles, :model, :string
    add_column :articles, :process, :string
    add_column :articles, :process_notes, :text
    add_column :articles, :image_options, :json
    add_column :articles, :image_selected, :string
  end
end
