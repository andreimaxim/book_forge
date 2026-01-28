class CreateAgents < ActiveRecord::Migration[8.1]
  def change
    create_table :agents do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email
      t.string :phone
      t.string :agency_name
      t.string :agency_website
      t.string :address_line1
      t.string :address_line2
      t.string :city
      t.string :state
      t.string :postal_code
      t.string :country, default: "USA"
      t.decimal :commission_rate, precision: 5, scale: 2, default: 15.00
      t.text :genres_represented
      t.text :notes
      t.string :status, default: "active"
      t.timestamps
    end

    add_index :agents, [ :last_name, :first_name ]
    add_index :agents, :agency_name
    add_index :agents, :status
    add_index :agents, :email, unique: true, where: "email IS NOT NULL"
  end
end
