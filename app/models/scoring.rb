class Scoring < ApplicationRecord
  belongs_to :game
  belongs_to :player

  def self.create_from_event(event)
    ap event
  end
end 