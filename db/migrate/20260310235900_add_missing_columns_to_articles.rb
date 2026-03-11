class AddMissingColumnsToArticles < ActiveRecord::Migration[7.0]
  def change
    add_column :articles, :title_summary, :string unless column_exists?(:articles, :title_summary)
    add_column :articles, :teams_json, :json unless column_exists?(:articles, :teams_json)
    add_column :articles, :people_json, :json unless column_exists?(:articles, :people_json)
    add_column :articles, :main_team_name, :string unless column_exists?(:articles, :main_team_name)
    add_column :articles, :main_team_slug, :string unless column_exists?(:articles, :main_team_slug)
    add_column :articles, :main_person_slug, :string unless column_exists?(:articles, :main_person_slug)
    add_column :articles, :scores_json, :json unless column_exists?(:articles, :scores_json)
    add_column :articles, :records_json, :json unless column_exists?(:articles, :records_json)
    add_column :articles, :key_stats_json, :json unless column_exists?(:articles, :key_stats_json)
    add_column :articles, :quotes_json, :json unless column_exists?(:articles, :quotes_json)
    add_column :articles, :context, :text unless column_exists?(:articles, :context)
    add_column :articles, :source_id, :string unless column_exists?(:articles, :source_id)
  end
end
