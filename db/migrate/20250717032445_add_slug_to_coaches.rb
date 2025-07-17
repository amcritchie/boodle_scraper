class AddSlugToCoaches < ActiveRecord::Migration[7.0]
  def change
    add_column :coaches, :slug, :string
    add_column :coaches, :defensive_play_caller_rank, :string
    add_index :coaches, :slug
  end
end
