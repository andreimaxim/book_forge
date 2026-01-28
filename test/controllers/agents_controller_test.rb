require "test_helper"
require "ostruct"

class AgentsControllerTest < ActionDispatch::IntegrationTest
  test "lists all agents" do
    get agents_path

    assert_response :ok
    assert_select "h1", "Agents"
    assert_select "[data-testid='agent-row']", Agent.count
  end

  test "groups agents by agency" do
    get agents_path(group_by: "agency")

    assert_response :ok
    assert_select "h1", "Agents"
    # Should have agency group headers for agencies with agents
    agencies = Agent.distinct.pluck(:agency_name).compact.sort
    agencies.each do |agency|
      assert_select "[data-testid='agency-group']", text: /#{Regexp.escape(agency)}/
    end
  end

  test "filters agents by status" do
    get agents_path(status: "active")

    assert_response :ok
    # Should only show active agents
    Agent.active.each do |agent|
      assert_select "[data-testid='agent-row']", text: /#{Regexp.escape(agent.full_name)}/
    end
  end

  test "filters agents by genre" do
    get agents_path(genre: "Mystery")

    assert_response :ok
    # Should show agents representing Mystery genre
    Agent.by_genre("Mystery").each do |agent|
      assert_select "[data-testid='agent-row']", text: /#{Regexp.escape(agent.full_name)}/
    end
  end

  test "shows agent details" do
    agent = agents(:simon_lipskar)

    get agent_path(agent)

    assert_response :ok
    assert_select "h1", agent.full_name
    assert_select "[data-testid='agent-email']", text: agent.email
    assert_select "[data-testid='agent-status']", text: /active/i
  end

  test "creates agent with valid data" do
    assert_difference("Agent.count", 1) do
      post agents_path, params: {
        agent: {
          first_name: "New",
          last_name: "Agent",
          email: "new.agent@example.com",
          agency_name: "New Literary Agency",
          commission_rate: 15.00,
          status: "active"
        }
      }
    end

    assert_redirected_to agent_path(Agent.last)
    follow_redirect!
    assert_select "[data-testid='flash-notice']", text: /Agent was successfully created/
  end

  test "updates agent with valid data" do
    agent = agents(:simon_lipskar)

    patch agent_path(agent), params: {
      agent: {
        first_name: "Updated",
        last_name: "Name",
        commission_rate: 18.00
      }
    }

    assert_redirected_to agent_path(agent)
    follow_redirect!
    assert_select "[data-testid='flash-notice']", text: /Agent was successfully updated/

    agent.reload
    assert_equal "Updated", agent.first_name
    assert_equal "Name", agent.last_name
    assert_equal 18.00, agent.commission_rate
  end

  test "deletes agent without associated records" do
    agent = agents(:agent_no_email)

    assert_difference("Agent.count", -1) do
      delete agent_path(agent)
    end

    assert_redirected_to agents_path
    follow_redirect!
    assert_select "[data-testid='flash-notice']", text: /Agent was successfully deleted/
  end
end
