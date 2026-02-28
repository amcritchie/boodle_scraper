class Task < ApplicationRecord
  belongs_to :taskable, polymorphic: true, optional: true

  MAX_RETRIES = 3
  
  validates :task_type, presence: true

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

  def can_retry?
    execute_count.to_i < MAX_RETRIES
  end

  def add_error(error_message)
    errors = (error_summary || []).dup
    errors << {
      "message" => error_message,
      "at" => Time.current.iso8601
    }
    update_column(:error_summary, errors)
  end
end
