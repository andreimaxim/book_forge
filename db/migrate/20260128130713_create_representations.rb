class CreateRepresentations < ActiveRecord::Migration[8.1]
  def change
    create_table :representations do |t|
      t.references :author, null: false, foreign_key: true
      t.references :agent, null: false, foreign_key: true
      t.string :status, default: "active"
      t.date :start_date
      t.date :end_date
      t.boolean :primary, default: false
      t.text :notes
      t.timestamps
    end

    add_index :representations, [ :author_id, :agent_id ], unique: true
    add_index :representations, :status
  end
end
