class AddVideoPathToNews < ActiveRecord::Migration[7.0]
  def change
    add_column :news, :video_path, :string
  end
end
