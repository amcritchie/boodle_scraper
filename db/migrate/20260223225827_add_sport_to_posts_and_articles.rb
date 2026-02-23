class AddSportToPostsAndArticles < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :sport, :string
    add_column :articles, :sport, :string
  end
end
