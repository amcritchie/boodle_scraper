class AddScoringCategoriesToWeeks < ActiveRecord::Migration[7.0]
  def change
    add_column :weeks, :passing_tds_4, :integer, default: 0
    add_column :weeks, :passing_tds_3, :integer, default: 0
    add_column :weeks, :passing_tds_2, :integer, default: 0
    add_column :weeks, :passing_tds_1, :integer, default: 0
    add_column :weeks, :passing_tds_0, :integer, default: 0
    
    add_column :weeks, :rushing_tds_4, :integer, default: 0
    add_column :weeks, :rushing_tds_3, :integer, default: 0
    add_column :weeks, :rushing_tds_2, :integer, default: 0
    add_column :weeks, :rushing_tds_1, :integer, default: 0
    add_column :weeks, :rushing_tds_0, :integer, default: 0
    
    add_column :weeks, :field_goals_5, :integer, default: 0
    add_column :weeks, :field_goals_4, :integer, default: 0
    add_column :weeks, :field_goals_3, :integer, default: 0
    add_column :weeks, :field_goals_2, :integer, default: 0
    add_column :weeks, :field_goals_1, :integer, default: 0
    add_column :weeks, :field_goals_0, :integer, default: 0
  end
end
