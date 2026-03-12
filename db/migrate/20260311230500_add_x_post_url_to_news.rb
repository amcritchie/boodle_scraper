class AddXPostUrlToNews < ActiveRecord::Migration[7.0]
  def change
    add_column :news, :x_post_url, :string
  end
end
