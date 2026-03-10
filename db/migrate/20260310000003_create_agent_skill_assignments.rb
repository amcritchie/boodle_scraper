class CreateAgentSkillAssignments < ActiveRecord::Migration[7.0]
  def change
    create_table :agent_skill_assignments do |t|
      t.string  :agent_slug, null: false
      t.string  :skill_slug, null: false
      t.integer :proficiency, default: 100

      t.timestamps
    end

    add_index :agent_skill_assignments, :agent_slug
    add_index :agent_skill_assignments, :skill_slug
    add_index :agent_skill_assignments, [:agent_slug, :skill_slug], unique: true, name: "idx_agent_skill_unique"
  end
end
