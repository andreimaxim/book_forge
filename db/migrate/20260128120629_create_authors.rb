class CreateAuthors < ActiveRecord::Migration[8.1]
  def change
    create_table :authors do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email
      t.string :phone
      t.text :bio
      t.string :website
      t.string :genre_focus
      t.string :status, default: "active"
      t.date :date_of_birth
      t.text :notes
      t.timestamps
    end

    add_index :authors, :email, unique: true, where: "email IS NOT NULL"
    add_index :authors, [:last_name, :first_name]
    add_index :authors, :status
  end
end
