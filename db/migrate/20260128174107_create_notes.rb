class CreateNotes < ActiveRecord::Migration[8.1]
  def change
    create_table :notes do |t|
      t.string :notable_type, null: false
      t.bigint :notable_id, null: false
      t.text :content, null: false
      t.boolean :pinned, default: false
      t.timestamps
    end

    add_index :notes, [ :notable_type, :notable_id ]
    add_index :notes, :pinned
    add_index :notes, :created_at
  end
end
