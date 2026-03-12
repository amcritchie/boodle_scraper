class AddOpinionFieldsToNews < ActiveRecord::Migration[7.0]
  def change
    add_column :news, :feeling,       :string
    add_column :news, :feeling_emoji, :string
    add_column :news, :what_happened, :string
  end
end
