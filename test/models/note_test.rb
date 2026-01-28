require "test_helper"

class NoteTest < ActiveSupport::TestCase
  test "requires notable" do
    note = Note.new(notable_type: nil, notable_id: nil, content: "Some content")
    assert_not note.valid?
    # belongs_to polymorphic validates the :notable association
    assert note.errors[:notable].any? || note.errors[:notable_type].any?,
      "Expected validation error on notable association"
  end

  test "requires content" do
    note = Note.new(
      notable_type: "Author",
      notable_id: ActiveRecord::FixtureSet.identify(:jane_austen),
      content: nil
    )
    assert_not note.valid?
    assert_includes note.errors[:content], "can't be blank"
  end

  test "validates content minimum length" do
    note = Note.new(
      notable_type: "Author",
      notable_id: ActiveRecord::FixtureSet.identify(:jane_austen),
      content: "x"
    )
    assert_not note.valid?
    assert_includes note.errors[:content], "is too short (minimum is 2 characters)"

    note.content = "ok"
    assert note.valid?
  end

  test "belongs to notable polymorphically" do
    author_note = notes(:author_pinned_note)
    assert_equal "Author", author_note.notable_type
    assert_equal authors(:jane_austen).id, author_note.notable_id
    assert_equal authors(:jane_austen), author_note.notable

    publisher_note = notes(:publisher_note)
    assert_equal "Publisher", publisher_note.notable_type
    assert_equal publishers(:penguin_random_house), publisher_note.notable

    book_note = notes(:book_note)
    assert_equal "Book", book_note.notable_type
    assert_equal books(:pride_and_prejudice), book_note.notable

    deal_note = notes(:deal_pinned_note)
    assert_equal "Deal", deal_note.notable_type
    assert_equal deals(:pride_and_prejudice_deal), deal_note.notable

    agent_note = notes(:agent_note)
    assert_equal "Agent", agent_note.notable_type
    assert_equal agents(:simon_lipskar), agent_note.notable

    prospect_note = notes(:prospect_note)
    assert_equal "Prospect", prospect_note.notable_type
    assert_equal prospects(:evaluating_prospect), prospect_note.notable
  end

  test "scopes pinned notes" do
    pinned_notes = Note.pinned

    assert_includes pinned_notes, notes(:author_pinned_note)
    assert_includes pinned_notes, notes(:deal_pinned_note)
    assert_not_includes pinned_notes, notes(:author_regular_note)
    assert_not_includes pinned_notes, notes(:publisher_note)
  end

  test "scopes notes by date descending" do
    notes_desc = Note.by_date(:desc)
    created_ats = notes_desc.map(&:created_at)
    assert_equal created_ats.sort.reverse, created_ats
  end

  test "scopes notes by date ascending" do
    notes_asc = Note.by_date(:asc)
    created_ats = notes_asc.map(&:created_at)
    assert_equal created_ats.sort, created_ats
  end

  test "orders by pinned first then by date" do
    ordered = Note.pinned_first

    # Collect the results
    results = ordered.to_a

    # All pinned notes should come before unpinned notes
    pinned_indices = results.each_index.select { |i| results[i].pinned? }
    unpinned_indices = results.each_index.select { |i| !results[i].pinned? }

    if pinned_indices.any? && unpinned_indices.any?
      assert pinned_indices.max < unpinned_indices.min,
        "Pinned notes should appear before unpinned notes"
    end

    # Within pinned notes, should be ordered by created_at desc
    pinned_results = results.select(&:pinned?)
    pinned_dates = pinned_results.map(&:created_at)
    assert_equal pinned_dates.sort.reverse, pinned_dates

    # Within unpinned notes, should be ordered by created_at desc
    unpinned_results = results.reject(&:pinned?)
    unpinned_dates = unpinned_results.map(&:created_at)
    assert_equal unpinned_dates.sort.reverse, unpinned_dates
  end

  test "renders markdown content as HTML" do
    note = notes(:markdown_note)
    html = note.rendered_content

    # Should contain rendered HTML elements
    assert_includes html, "<h1>"
    assert_includes html, "<strong>"
    assert_includes html, "<em>"
    assert_includes html, "<li>"
    assert_includes html, "<blockquote>"
    assert_includes html, "<a "
    assert_includes html, 'href="https://example.com"'
  end

  test "renders basic markdown formatting" do
    note = Note.new(content: "This is **bold** and *italic* text.")
    html = note.rendered_content

    assert_includes html, "<strong>bold</strong>"
    assert_includes html, "<em>italic</em>"
  end

  test "sanitizes HTML in rendered content" do
    note = notes(:xss_note)
    html = note.rendered_content

    # Should NOT contain script tags or event handler attributes
    assert_not_includes html, "<script>"
    assert_not_includes html, "</script>"
    assert_not_includes html, "onerror="

    # Should still contain the safe text parts
    assert_includes html, "Author feedback:"
    assert_includes html, "end of note."
  end

  test "sanitizes dangerous attributes in markdown links" do
    note = Note.new(content: '[click me](javascript:alert("xss"))')
    html = note.rendered_content

    # Should NOT render a clickable link with javascript: protocol
    assert_not_includes html, 'href="javascript:'
  end

  test "returns preview of content" do
    note = notes(:long_note)
    preview = note.preview

    assert_equal 100, preview.length
    assert preview.end_with?("...")
  end

  test "returns full content when shorter than preview length" do
    note = Note.new(content: "Short note.")
    preview = note.preview

    assert_equal "Short note.", preview
  end

  test "returns custom length preview" do
    note = notes(:long_note)
    preview = note.preview(50)

    assert_equal 50, preview.length
    assert preview.end_with?("...")
  end

  test "returns empty string for blank content preview" do
    note = Note.new(content: nil)
    assert_equal "", note.preview

    note = Note.new(content: "")
    assert_equal "", note.preview
  end

  test "pinned defaults to false" do
    note = Note.new(
      notable_type: "Author",
      notable_id: 1,
      content: "A new note"
    )
    assert_equal false, note.pinned
  end
end
