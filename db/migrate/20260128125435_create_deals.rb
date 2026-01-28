class CreateDeals < ActiveRecord::Migration[8.1]
  def change
    create_table :deals do |t|
      t.references :book, null: false, foreign_key: true
      t.references :publisher, null: false, foreign_key: true
      t.references :agent, foreign_key: true
      t.string :deal_type, null: false
      t.decimal :advance_amount, precision: 12, scale: 2
      t.string :advance_currency, default: "USD"
      t.decimal :royalty_rate_hardcover, precision: 5, scale: 2
      t.decimal :royalty_rate_paperback, precision: 5, scale: 2
      t.decimal :royalty_rate_ebook, precision: 5, scale: 2
      t.string :status, default: "negotiating"
      t.date :offer_date
      t.date :contract_date
      t.date :delivery_date
      t.date :publication_date
      t.integer :option_books
      t.text :terms_summary
      t.text :notes

      t.timestamps
    end

    add_index :deals, :status
    add_index :deals, :deal_type
    add_index :deals, :offer_date
    add_index :deals, :contract_date
  end
end
