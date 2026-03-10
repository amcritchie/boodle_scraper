class AddTitleToAgents < ActiveRecord::Migration[7.0]
  def change
    add_column :agents, :title, :string
  end
end
