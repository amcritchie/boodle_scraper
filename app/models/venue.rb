class Venue < ApplicationRecord
  has_many :games
  has_many :teams, foreign_key: :venue_slug, primary_key: :slug

  validates :name, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :country, presence: true

  def emoji
    if self.country.downcase == "esp"
      "🇪🇸"
    elsif self.country.downcase == "mex"
      "🇲🇽"
    elsif self.country.downcase == "deu"
      "🇩🇪"
    elsif self.country.downcase == "gbr"
      "🇬🇧"
    elsif self.country.downcase == "irl"
      "🇮🇪"
    elsif self.country.downcase == "bra"
      "🇧🇷"
    elsif self.true_home
       self.teams.first.emoji + " 🏠"
    else
      "⁉️"
    end
  end
end 