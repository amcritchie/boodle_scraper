class AddPositionStarterToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :position_starter, :string, after: :position
    add_column :players, :left_handed, :boolean, default: false, after: :position_starter
  end
end
