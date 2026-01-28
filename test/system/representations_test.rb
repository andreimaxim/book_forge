require "application_system_test_case"

class RepresentationsSystemTest < ApplicationSystemTestCase
  test "adding agent to author from author page" do
    author = authors(:author_without_books)

    # First verify the author has no agents
    assert_equal 0, author.representations.count

    visit author_path(author)

    # Navigate to the Agents tab
    within "[data-testid='author-tabs']" do
      click_link "Agents"
    end

    # Should see the empty state and form to add agent
    within "[data-testid='agents-tab-content']" do
      assert_text "Add Agent"
      assert_text "No agents yet"
    end

    # Select an agent from the dropdown and add them
    within "[data-testid='agents-tab-content']" do
      select "Simon Lipskar (Writers House)", from: "representation_agent_id"
      click_button "Add"
    end

    # Should now see the agent in the list (wait for turbo stream to complete)
    within "[data-testid='agents-tab-content']" do
      assert_selector "[data-testid='representation-row']", text: "Simon Lipskar"
      assert_text "Writers House"
    end

    # Verify in database
    author.reload
    assert_equal 1, author.representations.count
    assert_equal agents(:simon_lipskar), author.representations.first.agent
  end

  test "adding author to agent from agent page" do
    agent = agents(:high_commission_agent)

    # First verify the agent has no authors
    assert_equal 0, agent.representations.count

    visit agent_path(agent)

    # Authors tab should be visible by default
    within "[data-testid='authors-tab-content']" do
      assert_text "Add Author"
      assert_text "No authors yet"
    end

    # Select an author from the dropdown and add them
    within "[data-testid='authors-tab-content']" do
      select "Deletable Author (Fiction)", from: "representation_author_id"
      click_button "Add"
    end

    # Should now see the author in the list (wait for turbo stream to complete)
    within "[data-testid='authors-tab-content']" do
      assert_selector "[data-testid='representation-row']", text: "Deletable Author"
      assert_text "Fiction"
    end

    # Verify in database
    agent.reload
    assert_equal 1, agent.representations.count
    assert_equal authors(:author_without_books), agent.representations.first.author
  end

  test "setting primary agent for author" do
    author = authors(:jane_austen)

    visit author_path(author)

    # Navigate to the Agents tab
    within "[data-testid='author-tabs']" do
      click_link "Agents"
    end

    # Jane Austen already has simon_lipskar as primary and romance_agent as secondary
    within "[data-testid='agents-tab-content']" do
      # Simon Lipskar should be marked as Primary
      assert_selector "[data-testid='representation-row']", text: "Simon Lipskar"
      assert_text "Primary"

      # Find the secondary agent's row (romance_agent = Emily Davis)
      rep_row = find("[data-testid='representation-row']", text: "Emily Davis")
      within(rep_row) do
        # Should have a "Set Primary" button since it's not primary
        click_button "Set Primary"
      end
    end

    # Wait for turbo stream to update and verify the change
    # The romance_agent should now be primary (with Primary badge)
    within "[data-testid='agents-tab-content']" do
      # Wait for the Emily Davis row to be updated with Primary badge
      emily_row = find("[data-testid='representation-row']", text: "Emily Davis")
      within(emily_row) do
        assert_text "Primary"
      end
    end

    # Verify in database - Emily Davis (romance_agent) should now be primary
    author.reload
    emily_rep = author.representations.find_by(agent: agents(:romance_agent))
    simon_rep = author.representations.find_by(agent: agents(:simon_lipskar))
    assert emily_rep.primary?
    assert_not simon_rep.primary?
  end

  test "ending a representation" do
    author = authors(:jane_austen)
    # Jane Austen has representation with romance_agent (secondary, active)
    representation = representations(:jane_austen_secondary)

    assert representation.current?
    assert_nil representation.end_date

    visit author_path(author)

    # Navigate to the Agents tab
    within "[data-testid='author-tabs']" do
      click_link "Agents"
    end

    # Find the secondary agent's row (romance_agent = Emily Davis) and end the representation
    within "[data-testid='agents-tab-content']" do
      rep_row = find("[data-testid='representation-row']", text: "Emily Davis")
      within(rep_row) do
        # Should see Active badge
        assert_text "Active"

        # Click end button - it will show a confirmation dialog
        accept_confirm "Are you sure you want to end this representation?" do
          click_button "End"
        end
      end
    end

    # Wait for turbo stream to update and verify the representation shows as ended
    within "[data-testid='agents-tab-content']" do
      rep_row = find("[data-testid='representation-row']", text: "Emily Davis")
      within(rep_row) do
        assert_text "Ended"
        assert_no_button "End"
        assert_no_button "Set Primary"
      end
    end

    # Verify in database
    representation.reload
    assert_not representation.current?
    assert representation.status == "ended"
    assert_not_nil representation.end_date
  end

  test "viewing representation history" do
    # Agatha Christie has both an ended and an active representation
    author = authors(:agatha_christie)

    visit author_path(author)

    # Navigate to the Agents tab
    within "[data-testid='author-tabs']" do
      click_link "Agents"
    end

    # Should see both active and ended representations
    within "[data-testid='agents-tab-content']" do
      # Active representation with Molly Friedrich
      molly_row = find("[data-testid='representation-row']", text: "Molly Friedrich")
      within(molly_row) do
        assert_text "Active"
        assert_text "Primary"
        assert_text "Since Jan 2023"  # start_date: 2023-01-01
      end

      # Ended representation with Esther Newberg
      esther_row = find("[data-testid='representation-row']", text: "Esther Newberg")
      within(esther_row) do
        assert_text "Ended"
        assert_text "Ended Dec 2022"  # end_date: 2022-12-31
        assert_no_button "End"
        assert_no_button "Set Primary"
      end
    end
  end
end
