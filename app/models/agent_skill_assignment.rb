class AgentSkillAssignment < ApplicationRecord
  belongs_to :agent, foreign_key: :agent_slug, primary_key: :slug
  belongs_to :agent_skill, foreign_key: :skill_slug, primary_key: :slug

  validates :agent_slug, uniqueness: { scope: :skill_slug }
end
