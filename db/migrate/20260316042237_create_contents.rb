class CreateContents < ActiveRecord::Migration[7.0]
  def change
    create_table :contents do |t|
      t.text :prompt
      t.text :caption
      t.text :script
      t.jsonb :prompts, default: [], null: false
      t.jsonb :video_parts, default: [], null: false
      t.jsonb :video_choice, default: [], null: false
      t.string :video_url
      t.string :stage, default: "idea", null: false
      t.integer :rank

      t.timestamps
    end
  end
end
