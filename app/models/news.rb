class News < ApplicationRecord
  validates :title, presence: true

  scope :by_stage, ->(stage) { where(stage: stage) }
  scope :recent, -> { order(created_at: :desc) }

  STAGES = %w[new reviewed content edited posted].freeze
  BOARD_STAGES = %w[new reviewed content edited posted archived].freeze

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

  def post!
    update!(stage: "posted")
  end

  def archive!
    update!(stage: "archived")
  end

  def x_tweet_url
    x_post_url.presence || (x_post_id.present? ? "https://x.com/i/web/status/#{x_post_id}" : nil)
  end

  def posted_to_x?
    x_post_id.present? || x_post_url.present?
  end
end
