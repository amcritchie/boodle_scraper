class AgentSkill < ApplicationRecord
  has_many :agent_skill_assignments, foreign_key: :skill_slug, primary_key: :slug, dependent: :destroy
  has_many :agents, through: :agent_skill_assignments

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  scope :by_category, ->(cat) { where(category: cat) }
end
