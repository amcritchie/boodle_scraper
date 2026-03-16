class AddArchivedAtToAgentTasks < ActiveRecord::Migration[7.0]
  def change
    add_column :agent_tasks, :archived_at, :datetime
  end
end
