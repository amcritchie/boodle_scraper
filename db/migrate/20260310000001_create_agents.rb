class CreateAgents < ActiveRecord::Migration[7.0]
  def change
    create_table :agents do |t|
      t.string  :name,        null: false
      t.string  :slug,        null: false
      t.string  :status,      default: "active"
      t.text    :description
      t.string  :avatar_url
      t.string  :agent_type
      t.jsonb   :config,      default: {}
      t.jsonb   :metadata,    default: {}
      t.datetime :last_active_at

      t.timestamps
    end

    add_index :agents, :slug, unique: true
  end
end
