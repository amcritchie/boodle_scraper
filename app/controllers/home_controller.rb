class HomeController < ApplicationController
  def index
    # Sample P/L data for the tracker widget
    @pl_data = [
      { game_slug: "buf-mia", bet_on: "buf", bet_type: "team_total", unit: 1, odds: 180, status: "won", payout: 180 },
      { game_slug: "kc-lv", bet_on: "kc", bet_type: "team_total", unit: 1, odds: -110, status: "won", payout: 91 },
      { game_slug: "dal-nyg", bet_on: "dal", bet_type: "team_total", unit: 1, odds: -110, status: "lost", payout: -100 },
      { game_slug: "gb-chi", bet_on: "gb", bet_type: "team_total", unit: 1, odds: 165, status: "won", payout: 165 },
      { game_slug: "ne-nyj", bet_on: "ne", bet_type: "team_total", unit: 1, odds: -110, status: "won", payout: 91 }
    ]
  end
end
