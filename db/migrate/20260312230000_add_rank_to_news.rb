class AddRankToNews < ActiveRecord::Migration[7.0]
  def change
    add_column :news, :rank, :integer
    add_index :news, :rank
  end
end
