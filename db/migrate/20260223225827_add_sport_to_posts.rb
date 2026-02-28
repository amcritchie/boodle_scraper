class AddSportToPosts < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :sport, :string unless column_exists?(:posts, :sport)
  end
end
