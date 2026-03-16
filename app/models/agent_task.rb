class AgentTask < ApplicationRecord
  belongs_to :agent, foreign_key: :agent_slug, primary_key: :slug, optional: true

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug, on: :create

  scope :by_stage, ->(stage) { where(stage: stage) }
  scope :unassigned, -> { where(agent_slug: nil) }
  scope :assigned, -> { where.not(agent_slug: nil) }
  scope :pending, -> { where(stage: %w[new queued]) }
  scope :active, -> { where(stage: "in_progress") }
  scope :completed, -> { where(stage: "done") }
  scope :failed, -> { where(stage: "failed") }
  scope :archived, -> { where(stage: "archived") }
  scope :high_priority, -> { where("priority >= ?", 1) }

  PRIORITY_LABELS = { 0 => "Normal", 1 => "High", 2 => "Urgent" }.freeze

  def priority_label
    PRIORITY_LABELS[priority] || "Normal"
  end

  def assign_to!(agent_slug_val)
    update!(agent_slug: agent_slug_val)
  end

  def queue!
    update!(stage: "queued", queued_at: Time.current)
  end

  def start!
    update!(stage: "in_progress", started_at: Time.current)
  end

  def complete!(result_data = {})
    update!(stage: "done", completed_at: Time.current, result: result_data)
  end

  def fail!(message = nil)
    update!(stage: "failed", failed_at: Time.current, error_message: message)
  end

  def archive!
    update!(stage: "archived", archived_at: Time.current)
  end

  private

  def generate_slug
    return if slug.present?
    base = title.to_s.parameterize
    self.slug = "#{base}-#{SecureRandom.hex(4)}"
  end
end
