class AddScoringFieldsToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :home_passing_touchdowns, :integer, default: 0
    add_column :games, :home_rushing_touchdowns, :integer, default: 0
    add_column :games, :home_field_goals, :integer, default: 0
    add_column :games, :home_extra_points, :integer, default: 0
    add_column :games, :away_passing_touchdowns, :integer, default: 0
    add_column :games, :away_rushing_touchdowns, :integer, default: 0
    add_column :games, :away_field_goals, :integer, default: 0
    add_column :games, :away_extra_points, :integer, default: 0
    add_column :games, :alt_points, :integer, default: 0
  end
end
