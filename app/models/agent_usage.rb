class AgentUsage < ApplicationRecord
  belongs_to :agent, foreign_key: :agent_slug, primary_key: :slug

  validates :agent_slug, presence: true
  validates :period_date, presence: true

  scope :for_agent, ->(slug) { where(agent_slug: slug) }
  scope :for_date_range, ->(start_date, end_date) { where(period_date: start_date..end_date) }
  scope :recent, -> { order(period_date: :desc) }

  def total_tokens
    tokens_in + tokens_out
  end

  def success_rate
    total = tasks_completed + tasks_failed
    return 0 if total.zero?
    (tasks_completed.to_f / total * 100).round(1)
  end
end
