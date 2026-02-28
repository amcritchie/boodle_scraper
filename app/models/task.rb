class Task < ApplicationRecord
  belongs_to :taskable, polymorphic: true, optional: true

  # Using plain string column, not enum
  # Valid statuses: idle, active, pending, running, completed, failed
  
  validates :task_type, presence: true

  # Tasks stuck running longer than this are considered hung
  STUCK_THRESHOLD_SECONDS = 120

  def duration
    return nil unless started_at && completed_at
    completed_at - started_at
  end

  def stuck?
    status == "active" && started_at && (Time.current - started_at > STUCK_THRESHOLD_SECONDS)
  end

  def idle?
    status == "idle"
  end

  def active?
    status == "active"
  end

  def failed?
    status == "failed"
  end

  def completed?
    status == "completed"
  end

  def pending?
    status == "pending"
  end

  def running?
    status == "running"
  end
end
