require "test_helper"

class ProspectsControllerTest < ActionDispatch::IntegrationTest
  test "lists all prospects" do
    get prospects_path

    assert_response :ok
    assert_select "h1", "Prospects"
    assert_select "[data-testid='prospect-row']", Prospect.count
  end

  test "displays prospects in pipeline view" do
    get prospects_path(view: "pipeline")

    assert_response :ok
    assert_select "h1", "Prospects"
    # Should have stage columns for active stages
    Prospect.stages.keys.each do |stage|
      next if %w[converted declined].include?(stage)
      assert_select "[data-testid='pipeline-stage-#{stage}']"
    end
  end

  test "filters prospects by stage" do
    get prospects_path(stage: "new")

    assert_response :ok
    # Should only show prospects in "new" stage
    Prospect.by_stage("new").each do |prospect|
      assert_select "[data-testid='prospect-row']", text: /#{Regexp.escape(prospect.full_name)}/
    end
  end

  test "filters prospects by source" do
    get prospects_path(source: "query_letter")

    assert_response :ok
    # Should only show prospects from query_letter source
    Prospect.by_source("query_letter").each do |prospect|
      assert_select "[data-testid='prospect-row']", text: /#{Regexp.escape(prospect.full_name)}/
    end
  end

  test "filters prospects by assigned agent" do
    agent = agents(:simon_lipskar)
    get prospects_path(agent_id: agent.id)

    assert_response :ok
    # Should only show prospects assigned to this agent
    Prospect.where(agent: agent).each do |prospect|
      assert_select "[data-testid='prospect-row']", text: /#{Regexp.escape(prospect.full_name)}/
    end
  end

  test "shows prospects needing follow up" do
    get prospects_path(follow_up: "today")

    assert_response :ok
    # Should only show prospects with follow up today
    Prospect.follow_up_today.each do |prospect|
      assert_select "[data-testid='prospect-row']", text: /#{Regexp.escape(prospect.full_name)}/
    end
  end

  test "shows prospect details" do
    prospect = prospects(:new_prospect)

    get prospect_path(prospect)

    assert_response :ok
    assert_select "h1", prospect.full_name
    assert_select "[data-testid='prospect-email']", text: prospect.email
    assert_select "[data-testid='prospect-stage']", text: /new/i
  end

  test "creates prospect with valid data" do
    assert_difference("Prospect.count", 1) do
      post prospects_path, params: {
        prospect: {
          first_name: "New",
          last_name: "Prospect",
          email: "new.prospect@example.com",
          source: "query_letter",
          stage: "new",
          genre_interest: "Literary Fiction",
          project_title: "A New Novel"
        }
      }
    end

    assert_redirected_to prospect_path(Prospect.last)
    follow_redirect!
    assert_select "[data-testid='flash-notice']", text: /Prospect was successfully created/
  end

  test "updates prospect stage" do
    prospect = prospects(:new_prospect)

    patch prospect_path(prospect), params: {
      prospect: {
        stage: "contacted"
      }
    }

    assert_redirected_to prospect_path(prospect)
    follow_redirect!
    assert_select "[data-testid='flash-notice']", text: /Prospect was successfully updated/

    prospect.reload
    assert_equal "contacted", prospect.stage
  end

  test "assigns agent to prospect" do
    prospect = prospects(:unassigned_prospect)
    agent = agents(:simon_lipskar)

    patch prospect_path(prospect), params: {
      prospect: {
        agent_id: agent.id
      }
    }

    assert_redirected_to prospect_path(prospect)
    follow_redirect!
    assert_select "[data-testid='flash-notice']", text: /Prospect was successfully updated/

    prospect.reload
    assert_equal agent, prospect.agent
  end

  test "converts prospect to author" do
    prospect = prospects(:negotiating_prospect)

    assert_difference("Author.count", 1) do
      post convert_prospect_path(prospect)
    end

    assert_redirected_to Author.last
    follow_redirect!
    assert_select "[data-testid='flash-notice']", text: /Prospect was successfully converted to author/

    prospect.reload
    assert_equal "converted", prospect.stage
  end

  test "marks prospect as declined" do
    prospect = prospects(:new_prospect)

    patch decline_prospect_path(prospect), params: {
      decline_reason: "Manuscript not ready"
    }

    assert_redirected_to prospect_path(prospect)
    follow_redirect!
    assert_select "[data-testid='flash-notice']", text: /Prospect was marked as declined/

    prospect.reload
    assert_equal "declined", prospect.stage
    assert_equal "Manuscript not ready", prospect.decline_reason
  end
end
