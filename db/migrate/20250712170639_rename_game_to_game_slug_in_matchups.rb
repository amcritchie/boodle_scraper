class RenameGameToGameSlugInMatchups < ActiveRecord::Migration[7.0]
  def change
    rename_column :matchups, :game, :game_slug
  end
end
