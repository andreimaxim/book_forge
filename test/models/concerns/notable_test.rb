require "test_helper"

class NotableTest < ActiveSupport::TestCase
  test "Author has many note_records" do
    author = authors(:jane_austen)
    assert_respond_to author, :note_records
    assert_includes author.note_records, notes(:author_pinned_note)
    assert_includes author.note_records, notes(:author_regular_note)
    assert_includes author.note_records, notes(:author_old_note)
  end

  test "Publisher has many note_records" do
    publisher = publishers(:penguin_random_house)
    assert_respond_to publisher, :note_records
    assert_includes publisher.note_records, notes(:publisher_note)
  end

  test "Agent has many note_records" do
    agent = agents(:simon_lipskar)
    assert_respond_to agent, :note_records
    assert_includes agent.note_records, notes(:agent_note)
  end

  test "Book has many note_records" do
    book = books(:pride_and_prejudice)
    assert_respond_to book, :note_records
    assert_includes book.note_records, notes(:book_note)
  end

  test "Deal has many note_records" do
    deal = deals(:pride_and_prejudice_deal)
    assert_respond_to deal, :note_records
    assert_includes deal.note_records, notes(:deal_pinned_note)
  end

  test "Prospect has many note_records" do
    prospect = prospects(:evaluating_prospect)
    assert_respond_to prospect, :note_records
    assert_includes prospect.note_records, notes(:prospect_note)
  end

  test "destroying a notable record destroys associated notes" do
    author = authors(:author_without_books)
    note = Note.create!(
      notable: author,
      content: "This note will be destroyed with the author"
    )

    assert_difference("Note.count", -1) do
      author.destroy
    end

    assert_not Note.exists?(note.id)
  end
end
