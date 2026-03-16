class Content < ApplicationRecord
  STAGES = %w[idea refined video_created edited queued posted].freeze

  validates :stage, inclusion: { in: STAGES }

  def refine!;        update!(stage: "refined");       end
  def video_create!;  update!(stage: "video_created"); end
  def edit!;          update!(stage: "edited");        end
  def queue!;         update!(stage: "queued");        end
  def post!;          update!(stage: "posted");        end
end
