class CreateArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :articles do |t|
      t.string    :title
      t.string    :title_summary
      t.string    :author
      t.string    :sport
      t.date      :published_at
      t.datetime  :reviewed_at
      t.json      :teams_json
      t.json      :people_json
      t.string    :main_team_name
      t.string    :main_team_slug
      t.string    :main_person_name
      t.string    :main_person_slug
      t.json      :scores_json
      t.json      :records_json
      t.json      :key_stats_json
      t.json      :quotes_json
      t.text      :context
      t.string    :source
      t.string    :source_url
      t.string    :source_id
      t.boolean   :article_good
      t.boolean   :person_identified
      t.boolean   :disposition_coherent
      t.text      :feedback

      t.timestamps
    end
  end
end
