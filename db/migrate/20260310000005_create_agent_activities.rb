class CreateAgentActivities < ActiveRecord::Migration[7.0]
  def change
    create_table :agent_activities do |t|
      t.string :agent_slug,    null: false
      t.string :activity_type, null: false
      t.text   :description
      t.string :task_slug
      t.jsonb  :metadata,      default: {}

      t.timestamps
    end

    add_index :agent_activities, :agent_slug
    add_index :agent_activities, :activity_type
  end
end
