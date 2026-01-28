require "test_helper"

class RepresentationsControllerTest < ActionDispatch::IntegrationTest
  test "creates representation between author and agent" do
    author = authors(:author_without_books)
    agent = agents(:inactive_agent)

    assert_difference("Representation.count", 1) do
      post author_representations_path(author), params: {
        representation: {
          agent_id: agent.id,
          status: "active",
          primary: true,
          notes: "New representation"
        }
      }
    end

    assert_redirected_to author_path(author)
    follow_redirect!
    assert_select "[data-testid='flash-notice']", text: /Representation was successfully created/
  end

  test "prevents duplicate representation" do
    representation = representations(:jane_austen_primary)
    author = representation.author
    agent = representation.agent

    assert_no_difference("Representation.count") do
      post author_representations_path(author), params: {
        representation: {
          agent_id: agent.id,
          status: "active"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select ".text-red-600", /already been taken/
  end

  test "updates representation status" do
    representation = representations(:jane_austen_secondary)

    patch author_representation_path(representation.author, representation), params: {
      representation: {
        status: "ended",
        end_date: Date.current
      }
    }

    assert_redirected_to author_path(representation.author)
    representation.reload
    assert_equal "ended", representation.status
    assert_equal Date.current, representation.end_date
  end

  test "sets agent as primary for author" do
    # jane_austen_secondary is not primary
    representation = representations(:jane_austen_secondary)
    primary_rep = representations(:jane_austen_primary)

    assert primary_rep.primary?
    assert_not representation.primary?

    patch author_representation_path(representation.author, representation), params: {
      representation: {
        primary: true
      }
    }

    assert_redirected_to author_path(representation.author)

    representation.reload
    primary_rep.reload

    assert representation.primary?
    assert_not primary_rep.primary?
  end

  test "ends representation" do
    representation = representations(:jane_austen_secondary)
    assert representation.current?

    delete author_representation_path(representation.author, representation)

    assert_redirected_to author_path(representation.author)

    representation.reload
    assert_equal "ended", representation.status
    assert_equal Date.current, representation.end_date
  end

  test "responds with turbo stream for create" do
    author = authors(:author_without_books)
    agent = agents(:inactive_agent)

    post author_representations_path(author), params: {
      representation: {
        agent_id: agent.id,
        status: "active"
      }
    }, as: :turbo_stream

    assert_response :ok
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert_match /turbo-stream/, response.body
  end

  test "responds with turbo stream for destroy" do
    representation = representations(:jane_austen_secondary)

    delete author_representation_path(representation.author, representation), as: :turbo_stream

    assert_response :ok
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert_match /turbo-stream/, response.body
  end

  # Test nested under agents as well
  test "creates representation from agent page" do
    author = authors(:author_without_books)
    agent = agents(:inactive_agent)

    assert_difference("Representation.count", 1) do
      post agent_representations_path(agent), params: {
        representation: {
          author_id: author.id,
          status: "active",
          primary: false
        }
      }
    end

    assert_redirected_to agent_path(agent)
    follow_redirect!
    assert_select "[data-testid='flash-notice']", text: /Representation was successfully created/
  end
end
