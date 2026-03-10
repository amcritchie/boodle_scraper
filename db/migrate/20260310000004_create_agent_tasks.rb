class CreateAgentTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :agent_tasks do |t|
      t.string   :title,           null: false
      t.string   :slug,            null: false
      t.text     :description
      t.string   :stage,           default: "new"
      t.integer  :priority,        default: 0
      t.string   :agent_slug
      t.jsonb    :required_skills, default: []
      t.jsonb    :result,          default: {}
      t.jsonb    :metadata,        default: {}
      t.datetime :queued_at
      t.datetime :started_at
      t.datetime :completed_at
      t.datetime :failed_at
      t.string   :error_message

      t.timestamps
    end

    add_index :agent_tasks, :slug, unique: true
    add_index :agent_tasks, :agent_slug
    add_index :agent_tasks, :stage
  end
end
