class CreateRankings < ActiveRecord::Migration[7.0]
  def change
    create_table :rankings do |t|
      t.integer :week, null: false
      t.integer :season, null: false
      t.integer :sample_size, null: true, default: nil # Sample size adjested
      t.string :ranking_slug, null: false
      t.string :ranking_slug_detail, null: false
      t.string :player_slug, null: false
      t.string :position  # C, LT, RT, LG, RG
      t.integer :rank_1  # grades_offense rank
      t.integer :rank_2  # grades_pass_block rank
      t.integer :rank_3  # grades_run_block rank
      
      t.timestamps
    end
    
    add_index :rankings, :ranking_slug
    add_index :rankings, :ranking_slug_detail
    add_index :rankings, :week
    add_index :rankings, :season
    add_index :rankings, :sample_size
    add_index :rankings, :player_slug
    add_index :rankings, :position
    add_index :rankings, [:ranking_slug, :week]
    add_index :rankings, [:ranking_slug, :rank_1]
    add_index :rankings, [:ranking_slug, :rank_2]
    add_index :rankings, [:ranking_slug, :rank_3]
  end
end
