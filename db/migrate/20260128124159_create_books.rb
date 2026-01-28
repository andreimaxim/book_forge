class CreateBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :books do |t|
      t.string :title, null: false
      t.string :subtitle
      t.references :author, null: false, foreign_key: true
      t.string :genre, null: false
      t.string :subgenre
      t.integer :word_count
      t.text :synopsis
      t.text :description
      t.string :status, default: "manuscript"
      t.string :isbn
      t.date :publication_date
      t.decimal :list_price, precision: 8, scale: 2
      t.string :format
      t.integer :page_count
      t.string :cover_image_url
      t.text :notes
      t.timestamps
    end

    add_index :books, :title
    add_index :books, :genre
    add_index :books, :status
    add_index :books, :isbn, unique: true, where: "isbn IS NOT NULL"
    add_index :books, :publication_date
  end
end
