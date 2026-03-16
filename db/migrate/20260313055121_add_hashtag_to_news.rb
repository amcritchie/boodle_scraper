class AddHashtagToNews < ActiveRecord::Migration[7.0]
  def change
    add_column :news, :hashtag, :string
  end
end
