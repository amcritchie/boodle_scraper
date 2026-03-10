class CreateAgentUsages < ActiveRecord::Migration[7.0]
  def change
    create_table :agent_usages do |t|
      t.string  :agent_slug,      null: false
      t.date    :period_date,     null: false
      t.string  :period_type,     default: "daily"
      t.string  :model
      t.integer :tokens_in,       default: 0
      t.integer :tokens_out,      default: 0
      t.integer :api_calls,       default: 0
      t.decimal :cost,            precision: 10, scale: 4, default: 0.0
      t.integer :tasks_completed, default: 0
      t.integer :tasks_failed,    default: 0
      t.jsonb   :metadata,        default: {}

      t.timestamps
    end

    add_index :agent_usages, [:agent_slug, :period_date], unique: true
    add_index :agent_usages, :agent_slug
  end
end
