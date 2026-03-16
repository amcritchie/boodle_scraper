class AddHashtagToTeams < ActiveRecord::Migration[7.0]
  def change
    add_column :teams, :hashtag, :string
  end
end
