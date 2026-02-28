class Task < ApplicationRecord
  belongs_to :taskable, polymorphic: true, optional: true

  # idle = waiting to be picked up by worker
  # active = currently being processed
  # pending = queued (legacy, can use idle)
  # running = legacy, use active
  # completed = finished successfully
  # failed = finished with error
  
  enum status: {
    idle: "idle",
    active: "active",
    pending: "pending",
    running: "running",
    completed: "completed",
    failed: "failed"
  }, _prefix: true

  validates :task_type, presence: true

  # Tasks stuck running longer than this are considered hung
  STUCK_THRESHOLD_SECONDS = 120

  def duration
    return nil unless started_at && completed_at
    completed_at - started_at
  end

  def stuck?
    active? && started_at && (Time.current - started_at > STUCK_THRESHOLD_SECONDS)
  end

  def idle?
    status == "idle"
  end

  def active?
    status == "active"
  end
end
