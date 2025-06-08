class Broadcast < ApplicationRecord
  belongs_to :game

  validates :network, presence: true
end 