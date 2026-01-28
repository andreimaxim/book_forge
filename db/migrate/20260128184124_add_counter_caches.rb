class AddCounterCaches < ActiveRecord::Migration[8.1]
  def change
    # Author counter caches
    add_column :authors, :books_count, :integer, default: 0, null: false

    # Publisher counter caches
    add_column :publishers, :deals_count, :integer, default: 0, null: false

    # Agent counter caches
    add_column :agents, :representations_count, :integer, default: 0, null: false

    # Backfill existing counts
    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE authors
          SET books_count = (SELECT COUNT(*) FROM books WHERE books.author_id = authors.id)
        SQL

        execute <<~SQL
          UPDATE publishers
          SET deals_count = (SELECT COUNT(*) FROM deals WHERE deals.publisher_id = publishers.id)
        SQL

        execute <<~SQL
          UPDATE agents
          SET representations_count = (SELECT COUNT(*) FROM representations WHERE representations.agent_id = agents.id)
        SQL
      end
    end
  end
end
