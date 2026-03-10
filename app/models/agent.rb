class Agent < ApplicationRecord
  has_many :agent_skill_assignments, foreign_key: :agent_slug, primary_key: :slug, dependent: :destroy
  has_many :agent_skills, through: :agent_skill_assignments
  has_many :agent_tasks, foreign_key: :agent_slug, primary_key: :slug, dependent: :nullify
  has_many :agent_activities, foreign_key: :agent_slug, primary_key: :slug, dependent: :destroy
  has_many :agent_usages, foreign_key: :agent_slug, primary_key: :slug, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  scope :active, -> { where(status: "active") }
  scope :inactive, -> { where(status: "inactive") }
  scope :paused, -> { where(status: "paused") }

  def tasks_by_stage
    agent_tasks.group(:stage).count
  end

  def total_cost
    agent_usages.sum(:cost)
  end
end
