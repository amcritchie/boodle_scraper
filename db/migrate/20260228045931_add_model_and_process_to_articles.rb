class AddModelAndProcessToArticles < ActiveRecord::Migration[7.0]
  def change
    add_column :articles, :model, :string
    add_column :articles, :process, :string
    add_column :articles, :process_notes, :text
  end
end
