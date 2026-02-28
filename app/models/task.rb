class Task < ApplicationRecord
  belongs_to :taskable, polymorphic: true, optional: true

  enum status: {
    pending: "pending",
    running: "running", 
    completed: "completed",
    failed: "failed"
  }, _prefix: true

  validates :task_type, presence: true

  def duration
    return nil unless started_at && completed_at
    completed_at - started_at
  end

  def pending?
    status == "pending"
  end

  def failed?
    status == "failed"
  end
end
