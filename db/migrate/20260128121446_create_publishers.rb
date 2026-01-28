class CreatePublishers < ActiveRecord::Migration[8.1]
  def change
    create_table :publishers do |t|
      t.string :name, null: false
      t.string :imprint
      t.string :address_line1
      t.string :address_line2
      t.string :city
      t.string :state
      t.string :postal_code
      t.string :country, default: "USA"
      t.string :phone
      t.string :website
      t.string :contact_name
      t.string :contact_email
      t.string :contact_phone
      t.string :size # big_five, major, mid_size, small, indie
      t.text :notes
      t.string :status, default: "active" # active, inactive
      t.timestamps
    end

    add_index :publishers, :name
    add_index :publishers, :size
    add_index :publishers, :status
  end
end
