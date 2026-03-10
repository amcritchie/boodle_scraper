class AgentActivity < ApplicationRecord
  belongs_to :agent, foreign_key: :agent_slug, primary_key: :slug
  belongs_to :agent_task, foreign_key: :task_slug, primary_key: :slug, optional: true

  validates :agent_slug, presence: true
  validates :activity_type, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(activity_type: type) }
  scope :for_agent, ->(slug) { where(agent_slug: slug) }
end
