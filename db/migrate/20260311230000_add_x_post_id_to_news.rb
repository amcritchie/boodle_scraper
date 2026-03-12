class AddXPostIdToNews < ActiveRecord::Migration[7.0]
  def change
    add_column :news, :x_post_id, :string
    add_index :news, :x_post_id, unique: true, where: "x_post_id IS NOT NULL"
  end
end
