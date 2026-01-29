require "test_helper"

class AgentTest < ActiveSupport::TestCase
  # Validation tests
  test "requires first name" do
    agent = Agent.new(first_name: nil, last_name: "Doe")
    assert_not agent.valid?
    assert_includes agent.errors[:first_name], "can't be blank"
  end

  test "requires last name" do
    agent = Agent.new(first_name: "John", last_name: nil)
    assert_not agent.valid?
    assert_includes agent.errors[:last_name], "can't be blank"
  end

  test "validates email format when provided" do
    agent = Agent.new(
      first_name: "John",
      last_name: "Doe",
      email: "invalid-email"
    )
    assert_not agent.valid?
    assert_includes agent.errors[:email], "is invalid"
  end

  test "allows valid email format" do
    agent = Agent.new(
      first_name: "John",
      last_name: "Doe",
      email: "john.doe@example.com"
    )
    assert agent.valid?
  end

  test "allows blank email" do
    agent = Agent.new(
      first_name: "John",
      last_name: "Doe",
      email: nil
    )
    assert agent.valid?
  end

  test "validates email uniqueness when provided" do
    existing_agent = agents(:simon_lipskar)
    agent = Agent.new(
      first_name: "Another",
      last_name: "Agent",
      email: existing_agent.email
    )
    assert_not agent.valid?
    assert_includes agent.errors[:email], "has already been taken"
  end

  test "allows multiple agents with blank email" do
    agent1 = Agent.create!(first_name: "First", last_name: "Agent", email: nil)
    agent2 = Agent.new(first_name: "Second", last_name: "Agent", email: nil)
    assert agent2.valid?
  end

  test "validates commission rate is between 0 and 100" do
    # Test negative commission
    agent = Agent.new(
      first_name: "John",
      last_name: "Doe",
      commission_rate: -5
    )
    assert_not agent.valid?
    assert_includes agent.errors[:commission_rate], "must be greater than or equal to 0"

    # Test commission over 100
    agent = Agent.new(
      first_name: "John",
      last_name: "Doe",
      commission_rate: 105
    )
    assert_not agent.valid?
    assert_includes agent.errors[:commission_rate], "must be less than or equal to 100"

    # Test valid commission rates
    [ 0, 15, 50, 100 ].each do |rate|
      agent = Agent.new(
        first_name: "John",
        last_name: "Doe",
        commission_rate: rate
      )
      assert agent.valid?, "Expected commission_rate #{rate} to be valid"
    end
  end

  test "allows nil commission rate" do
    agent = Agent.new(
      first_name: "John",
      last_name: "Doe",
      commission_rate: nil
    )
    assert agent.valid?
  end

  test "raises error for invalid status value" do
    assert_raises(ArgumentError) do
      Agent.new(
        first_name: "John",
        last_name: "Doe",
        status: "unknown_status"
      )
    end
  end

  test "allows valid status values" do
    %w[active inactive not_accepting].each do |valid_status|
      agent = Agent.new(
        first_name: "John",
        last_name: "Doe",
        status: valid_status
      )
      assert agent.valid?, "Expected status '#{valid_status}' to be valid"
    end
  end

  # Instance method tests
  test "returns full name" do
    agent = Agent.new(first_name: "Simon", last_name: "Lipskar")
    assert_equal "Simon Lipskar", agent.full_name
  end

  test "returns full name with agency" do
    agent = Agent.new(
      first_name: "Simon",
      last_name: "Lipskar",
      agency_name: "Writers House"
    )
    assert_equal "Simon Lipskar (Writers House)", agent.full_name_with_agency
  end

  test "returns full name with agency when no agency present" do
    agent = Agent.new(
      first_name: "Simon",
      last_name: "Lipskar",
      agency_name: nil
    )
    assert_equal "Simon Lipskar", agent.full_name_with_agency
  end

  test "returns genres as array" do
    agent = Agent.new(genres_represented: "Literary Fiction, Science Fiction, Fantasy")
    expected = [ "Literary Fiction", "Science Fiction", "Fantasy" ]
    assert_equal expected, agent.genres_array
  end

  test "returns empty array when genres_represented is blank" do
    agent = Agent.new(genres_represented: nil)
    assert_equal [], agent.genres_array

    agent = Agent.new(genres_represented: "")
    assert_equal [], agent.genres_array
  end

  test "sets genres from array" do
    agent = Agent.new(first_name: "John", last_name: "Doe")
    agent.genres_array = [ "Mystery", "Thriller", "Crime Fiction" ]
    assert_equal "Mystery, Thriller, Crime Fiction", agent.genres_represented
  end

  test "sets genres_represented to nil when given empty array" do
    agent = Agent.new(first_name: "John", last_name: "Doe")
    agent.genres_array = []
    assert_nil agent.genres_represented
  end

  test "calculates commission for amount" do
    agent = Agent.new(commission_rate: 15.00)
    assert_equal 150.00, agent.commission_for(1000)
    assert_equal 1500.00, agent.commission_for(10000)
    assert_equal 0.00, agent.commission_for(0)
  end

  test "calculates commission with nil commission rate returns zero" do
    agent = Agent.new(commission_rate: nil)
    assert_equal 0.00, agent.commission_for(1000)
  end

  # Scope tests
  test "scopes active agents" do
    active_agents = Agent.active

    assert_includes active_agents, agents(:simon_lipskar)
    assert_includes active_agents, agents(:esther_newberg)
    assert_not_includes active_agents, agents(:inactive_agent)
    assert_not_includes active_agents, agents(:not_accepting_agent)
  end

  test "scopes agents accepting new clients" do
    accepting_agents = Agent.accepting_clients

    assert_includes accepting_agents, agents(:simon_lipskar)
    assert_includes accepting_agents, agents(:esther_newberg)
    assert_not_includes accepting_agents, agents(:inactive_agent)
    assert_not_includes accepting_agents, agents(:not_accepting_agent)
  end

  test "scopes agents by agency" do
    icm_agents = Agent.by_agency("ICM Partners")

    assert_includes icm_agents, agents(:esther_newberg)
    assert_includes icm_agents, agents(:jennifer_joel)
    assert_not_includes icm_agents, agents(:simon_lipskar)
    assert_not_includes icm_agents, agents(:molly_friedrich)
  end

  test "scopes agents by genre represented" do
    # Agents who represent Literary Fiction
    literary_agents = Agent.by_genre("Literary Fiction")

    assert_includes literary_agents, agents(:simon_lipskar)
    assert_includes literary_agents, agents(:esther_newberg)
    assert_includes literary_agents, agents(:molly_friedrich)
    assert_not_includes literary_agents, agents(:mystery_agent)
    assert_not_includes literary_agents, agents(:romance_agent)
  end

  test "scopes agents by genre represented is case insensitive" do
    mystery_agents = Agent.by_genre("mystery")
    assert_includes mystery_agents, agents(:mystery_agent)

    mystery_agents = Agent.by_genre("MYSTERY")
    assert_includes mystery_agents, agents(:mystery_agent)
  end

  test "searches agents by name" do
    # Search by last name
    results = Agent.search("Lipskar")
    assert_includes results, agents(:simon_lipskar)
    assert_not_includes results, agents(:esther_newberg)

    # Search by first name
    results = Agent.search("Esther")
    assert_includes results, agents(:esther_newberg)
    assert_not_includes results, agents(:simon_lipskar)
  end

  test "searches agents by agency name" do
    results = Agent.search("Writers House")
    assert_includes results, agents(:simon_lipskar)
    assert_not_includes results, agents(:esther_newberg)

    results = Agent.search("ICM")
    assert_includes results, agents(:esther_newberg)
    assert_includes results, agents(:jennifer_joel)
  end

  test "search is case insensitive" do
    results = Agent.search("lipskar")
    assert_includes results, agents(:simon_lipskar)

    results = Agent.search("WRITERS HOUSE")
    assert_includes results, agents(:simon_lipskar)
  end

  test "orders agents alphabetically by last name" do
    ordered = Agent.alphabetical

    # Get all last names in order
    last_names = ordered.pluck(:last_name)

    # Verify they are sorted
    assert_equal last_names.sort, last_names
  end
end
