class News < ApplicationRecord
  validates :title, presence: true
  validates :url, uniqueness: { scope: :content_type }, allow_blank: true, on: :create

  scope :by_stage, ->(stage) { where(stage: stage) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_rank, -> { order(Arel.sql("COALESCE(rank, 999999999) ASC, created_at DESC")) }

  CONTENT_TYPES = %w[x_post x_reply].freeze
  STAGES = %w[new reviewed content edited queued posted].freeze
  BOARD_STAGES = %w[new reviewed content edited queued posted archived].freeze

  scope :active, -> { where.not(stage: "archived") }
  scope :archived, -> { where(stage: "archived") }

  def review!
    update!(stage: "reviewed")
  end

  def write_content!
    update!(stage: "content")
  end

  def edit!
    update!(stage: "edited")
  end

  def queue!
    update!(stage: "queued")
  end

  def post!
    update!(stage: "posted")
  end

  def archive!
    update!(stage: "archived")
  end

  def posted_to_x?
    x_post_id.present? || x_post_url.present?
  end
end
