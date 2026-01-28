class CreateActivities < ActiveRecord::Migration[8.1]
  def change
    create_table :activities do |t|
      t.string :trackable_type, null: false
      t.bigint :trackable_id, null: false
      t.string :action, null: false
      t.string :field_changed
      t.text :old_value
      t.text :new_value
      t.text :description
      t.jsonb :metadata, default: {}
      t.timestamps
    end

    add_index :activities, [ :trackable_type, :trackable_id ]
    add_index :activities, :action
    add_index :activities, :created_at
  end
end
