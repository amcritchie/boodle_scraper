class AddDefaultRankToNews < ActiveRecord::Migration[7.0]
  def up
    News.where(rank: nil).update_all(rank: 100)
  end

  def down
    # irreversible — ranks are not nulled out on rollback
  end
end
