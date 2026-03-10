class CreateAgentSkills < ActiveRecord::Migration[7.0]
  def change
    create_table :agent_skills do |t|
      t.string :name,     null: false
      t.string :slug,     null: false
      t.string :category
      t.text   :description
      t.jsonb  :config,   default: {}

      t.timestamps
    end

    add_index :agent_skills, :slug, unique: true
  end
end
