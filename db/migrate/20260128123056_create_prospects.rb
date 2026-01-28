class CreateProspects < ActiveRecord::Migration[8.1]
  def change
    create_table :prospects do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email
      t.string :phone
      t.string :source # query_letter, referral, conference, social_media, website, other
      t.string :stage, default: "new" # new, contacted, evaluating, negotiating, converted, declined
      t.string :genre_interest
      t.string :project_title
      t.text :project_description
      t.integer :estimated_word_count
      t.text :notes
      t.references :agent, foreign_key: true # assigned agent
      t.date :last_contact_date
      t.date :follow_up_date
      t.datetime :stage_changed_at
      t.text :decline_reason
      t.timestamps
    end

    add_index :prospects, :stage
    add_index :prospects, :source
    add_index :prospects, :follow_up_date
    add_index :prospects, [ :last_name, :first_name ]
  end
end
