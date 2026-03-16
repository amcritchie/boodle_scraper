class AddContentTypeAndMemeIdToNews < ActiveRecord::Migration[7.0]
  def change
    add_column :news, :content_type, :string, default: 'x_post'
    add_column :news, :meme_id, :integer
  end
end
