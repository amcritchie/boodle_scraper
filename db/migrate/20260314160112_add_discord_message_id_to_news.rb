class AddDiscordMessageIdToNews < ActiveRecord::Migration[7.0]
  def change
    add_column :news, :discord_message_id, :string
  end
end
