class CreateAgents < ActiveRecord::Migration[7.0]
  def change
    create_table :agents do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :status, default: "active"
      t.text :description
      t.string :avatar_url
      t.string :agent_type
      t.string :title
      t.jsonb :config, default: {}
      t.jsonb :metadata, default: {}
      t.datetime :last_active_at
      t.timestamps
    end

    add_index :agents, :slug, unique: true

    create_table :agent_skills do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :category
      t.text :description
      t.jsonb :config, default: {}
      t.timestamps
    end

    add_index :agent_skills, :slug, unique: true

    create_table :agent_skill_assignments do |t|
      t.string :agent_slug, null: false
      t.string :skill_slug, null: false
      t.integer :proficiency, default: 100
      t.timestamps
    end

    add_index :agent_skill_assignments, :agent_slug
    add_index :agent_skill_assignments, :skill_slug
    add_index :agent_skill_assignments, [:agent_slug, :skill_slug], unique: true, name: "idx_agent_skill_unique"

    create_table :agent_tasks do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.text :description
      t.string :stage, default: "new"
      t.integer :priority, default: 0
      t.string :agent_slug
      t.jsonb :required_skills, default: []
      t.jsonb :result, default: {}
      t.jsonb :metadata, default: {}
      t.datetime :queued_at
      t.datetime :started_at
      t.datetime :completed_at
      t.datetime :failed_at
      t.string :error_message
      t.datetime :archived_at
      t.timestamps
    end

    add_index :agent_tasks, :slug, unique: true
    add_index :agent_tasks, :agent_slug
    add_index :agent_tasks, :stage

    create_table :agent_activities do |t|
      t.string :agent_slug, null: false
      t.string :activity_type, null: false
      t.text :description
      t.string :task_slug
      t.jsonb :metadata, default: {}
      t.timestamps
    end

    add_index :agent_activities, :agent_slug
    add_index :agent_activities, :activity_type

    create_table :agent_usages do |t|
      t.string :agent_slug, null: false
      t.date :period_date, null: false
      t.string :period_type, default: "daily"
      t.string :model
      t.integer :tokens_in, default: 0
      t.integer :tokens_out, default: 0
      t.integer :api_calls, default: 0
      t.decimal :cost, precision: 10, scale: 4, default: "0.0"
      t.integer :tasks_completed, default: 0
      t.integer :tasks_failed, default: 0
      t.jsonb :metadata, default: {}
      t.timestamps
    end

    add_index :agent_usages, :agent_slug
    add_index :agent_usages, [:agent_slug, :period_date], unique: true
  end
end
