require "test_helper"

class RepresentationTest < ActiveSupport::TestCase
  test "requires author" do
    representation = Representation.new(
      author: nil,
      agent: agents(:simon_lipskar)
    )
    assert_not representation.valid?
    assert_includes representation.errors[:author], "must exist"
  end

  test "requires agent" do
    representation = Representation.new(
      author: authors(:jane_austen),
      agent: nil
    )
    assert_not representation.valid?
    assert_includes representation.errors[:agent], "must exist"
  end

  test "validates uniqueness of author and agent combination" do
    existing = representations(:jane_austen_primary)
    duplicate = Representation.new(
      author: existing.author,
      agent: existing.agent
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:author_id], "has already been taken"
  end

  test "validates status is a known value" do
    representation = Representation.new(
      author: authors(:author_without_books),
      agent: agents(:inactive_agent),
      status: "invalid_status"
    )
    assert_not representation.valid?
    assert_includes representation.errors[:status], "is not included in the list"
  end

  test "validates end date is after start date" do
    representation = Representation.new(
      author: authors(:author_without_books),
      agent: agents(:inactive_agent),
      start_date: Date.new(2023, 6, 1),
      end_date: Date.new(2023, 1, 1)
    )
    assert_not representation.valid?
    assert_includes representation.errors[:end_date], "must be after start date"
  end

  test "scopes active representations" do
    active_reps = Representation.active

    assert_includes active_reps, representations(:jane_austen_primary)
    assert_includes active_reps, representations(:stephen_king_rep)
    assert_not_includes active_reps, representations(:agatha_christie_ended)
  end

  test "scopes ended representations" do
    ended_reps = Representation.ended

    assert_includes ended_reps, representations(:agatha_christie_ended)
    assert_not_includes ended_reps, representations(:jane_austen_primary)
    assert_not_includes ended_reps, representations(:stephen_king_rep)
  end

  test "ensures only one primary agent per author" do
    author = authors(:jane_austen)
    original_primary = representations(:jane_austen_primary)
    secondary = representations(:jane_austen_secondary)

    # Verify initial state
    assert original_primary.primary?
    assert_not secondary.primary?

    # Set secondary as primary
    secondary.update!(primary: true)

    # Original should no longer be primary
    original_primary.reload
    assert_not original_primary.primary?
    assert secondary.primary?
  end

  test "automatically sets start date to today if not provided" do
    representation = Representation.create!(
      author: authors(:author_without_books),
      agent: agents(:inactive_agent),
      start_date: nil
    )
    assert_equal Date.current, representation.start_date
  end

  test "ends representation and sets end date" do
    representation = representations(:jane_austen_primary)
    assert_equal "active", representation.status
    assert_nil representation.end_date

    representation.end_representation!

    assert_equal "ended", representation.status
    assert_equal Date.current, representation.end_date
  end

  test "determines if representation is current" do
    active_rep = representations(:jane_austen_primary)
    ended_rep = representations(:agatha_christie_ended)

    assert active_rep.current?
    assert_not ended_rep.current?
  end

  test "calculates representation duration" do
    # For ended representation with both dates
    ended_rep = representations(:agatha_christie_ended)
    # start_date: 2018-01-01, end_date: 2022-12-31 = ~5 years
    expected_days = (Date.new(2022, 12, 31) - Date.new(2018, 1, 1)).to_i
    assert_equal expected_days, ended_rep.duration_in_days

    # For active representation, use today as end date
    active_rep = representations(:jane_austen_primary)
    # start_date: 2020-01-15
    expected_days = (Date.current - Date.new(2020, 1, 15)).to_i
    assert_equal expected_days, active_rep.duration_in_days
  end

  # Association tests
  test "author has many agents through representations" do
    author = authors(:jane_austen)
    assert_includes author.agents, agents(:simon_lipskar)
    assert_includes author.agents, agents(:romance_agent)
  end

  test "agent has many authors through representations" do
    agent = agents(:simon_lipskar)
    assert_includes agent.authors, authors(:jane_austen)
  end

  test "destroying representation removes it from author" do
    author = authors(:jane_austen)
    representation = representations(:jane_austen_secondary)
    agent = representation.agent

    initial_count = author.agents.count
    representation.destroy

    assert_equal initial_count - 1, author.agents.count
    assert_not_includes author.agents.reload, agent
  end
end
