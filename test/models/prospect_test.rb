require "test_helper"

class ProspectTest < ActiveSupport::TestCase
  # Validation tests
  test "requires first name" do
    prospect = Prospect.new(first_name: nil, last_name: "Doe")
    assert_not prospect.valid?
    assert_includes prospect.errors[:first_name], "can't be blank"
  end

  test "requires last name" do
    prospect = Prospect.new(first_name: "John", last_name: nil)
    assert_not prospect.valid?
    assert_includes prospect.errors[:last_name], "can't be blank"
  end

  test "validates email format when provided" do
    prospect = Prospect.new(
      first_name: "John",
      last_name: "Doe",
      email: "invalid-email"
    )
    assert_not prospect.valid?
    assert_includes prospect.errors[:email], "is invalid"
  end

  test "allows valid email format" do
    prospect = Prospect.new(
      first_name: "John",
      last_name: "Doe",
      email: "john.doe@example.com"
    )
    assert prospect.valid?
  end

  test "allows blank email" do
    prospect = Prospect.new(
      first_name: "John",
      last_name: "Doe",
      email: nil
    )
    assert prospect.valid?
  end

  test "raises error for invalid source value" do
    assert_raises(ArgumentError) do
      Prospect.new(
        first_name: "John",
        last_name: "Doe",
        source: "unknown_source"
      )
    end
  end

  test "allows valid source values" do
    %w[query_letter referral conference social_media website other].each do |valid_source|
      prospect = Prospect.new(
        first_name: "John",
        last_name: "Doe",
        source: valid_source
      )
      assert prospect.valid?, "Expected source '#{valid_source}' to be valid"
    end
  end

  test "allows blank source" do
    prospect = Prospect.new(
      first_name: "John",
      last_name: "Doe",
      source: nil
    )
    assert prospect.valid?
  end

  test "raises error for invalid stage value" do
    assert_raises(ArgumentError) do
      Prospect.new(
        first_name: "John",
        last_name: "Doe",
        stage: "unknown_stage"
      )
    end
  end

  test "allows valid stage values" do
    %w[new contacted evaluating negotiating converted declined].each do |valid_stage|
      prospect = Prospect.new(
        first_name: "John",
        last_name: "Doe",
        stage: valid_stage
      )
      assert prospect.valid?, "Expected stage '#{valid_stage}' to be valid"
    end
  end

  test "validates estimated word count is positive" do
    # Test negative word count
    prospect = Prospect.new(
      first_name: "John",
      last_name: "Doe",
      estimated_word_count: -1000
    )
    assert_not prospect.valid?
    assert_includes prospect.errors[:estimated_word_count], "must be greater than 0"

    # Test zero word count
    prospect = Prospect.new(
      first_name: "John",
      last_name: "Doe",
      estimated_word_count: 0
    )
    assert_not prospect.valid?
    assert_includes prospect.errors[:estimated_word_count], "must be greater than 0"

    # Test valid word count
    prospect = Prospect.new(
      first_name: "John",
      last_name: "Doe",
      estimated_word_count: 80000
    )
    assert prospect.valid?
  end

  test "allows nil estimated word count" do
    prospect = Prospect.new(
      first_name: "John",
      last_name: "Doe",
      estimated_word_count: nil
    )
    assert prospect.valid?
  end

  # Instance method tests
  test "returns full name" do
    prospect = Prospect.new(first_name: "Sarah", last_name: "Johnson")
    assert_equal "Sarah Johnson", prospect.full_name
  end

  # Scope tests
  test "scopes prospects by stage" do
    new_prospects = Prospect.by_stage("new")
    contacted_prospects = Prospect.by_stage("contacted")

    assert_includes new_prospects, prospects(:new_prospect)
    assert_includes new_prospects, prospects(:unassigned_prospect)
    assert_not_includes new_prospects, prospects(:contacted_prospect)

    assert_includes contacted_prospects, prospects(:contacted_prospect)
    assert_includes contacted_prospects, prospects(:follow_up_today)
    assert_not_includes contacted_prospects, prospects(:new_prospect)
  end

  test "scopes prospects by source" do
    query_prospects = Prospect.by_source("query_letter")
    referral_prospects = Prospect.by_source("referral")

    assert_includes query_prospects, prospects(:new_prospect)
    assert_includes query_prospects, prospects(:declined_prospect)
    assert_not_includes query_prospects, prospects(:contacted_prospect)

    assert_includes referral_prospects, prospects(:evaluating_prospect)
    assert_includes referral_prospects, prospects(:follow_up_today)
    assert_not_includes referral_prospects, prospects(:new_prospect)
  end

  test "scopes prospects needing follow up today" do
    follow_up_today_prospects = Prospect.follow_up_today

    assert_includes follow_up_today_prospects, prospects(:contacted_prospect)
    assert_includes follow_up_today_prospects, prospects(:follow_up_today)
    assert_not_includes follow_up_today_prospects, prospects(:follow_up_this_week)
    assert_not_includes follow_up_today_prospects, prospects(:new_prospect)
  end

  test "scopes prospects needing follow up this week" do
    follow_up_week_prospects = Prospect.follow_up_this_week

    assert_includes follow_up_week_prospects, prospects(:contacted_prospect)
    assert_includes follow_up_week_prospects, prospects(:follow_up_today)
    assert_includes follow_up_week_prospects, prospects(:follow_up_this_week)
    assert_not_includes follow_up_week_prospects, prospects(:evaluating_prospect)
  end

  test "scopes prospects overdue for follow up" do
    overdue_prospects = Prospect.overdue_follow_up

    assert_includes overdue_prospects, prospects(:overdue_follow_up)
    assert_not_includes overdue_prospects, prospects(:follow_up_today)
    assert_not_includes overdue_prospects, prospects(:follow_up_this_week)
    assert_not_includes overdue_prospects, prospects(:new_prospect)
  end

  test "scopes unassigned prospects" do
    unassigned = Prospect.unassigned

    assert_includes unassigned, prospects(:new_prospect)
    assert_includes unassigned, prospects(:unassigned_prospect)
    assert_includes unassigned, prospects(:prospect_no_email)
    assert_not_includes unassigned, prospects(:contacted_prospect)
    assert_not_includes unassigned, prospects(:evaluating_prospect)
  end

  test "searches prospects by name" do
    # Search by last name
    results = Prospect.search("Johnson")
    assert_includes results, prospects(:new_prospect)
    assert_not_includes results, prospects(:contacted_prospect)

    # Search by first name
    results = Prospect.search("Sarah")
    assert_includes results, prospects(:new_prospect)
    assert_not_includes results, prospects(:contacted_prospect)

    # Case insensitive search
    results = Prospect.search("johnson")
    assert_includes results, prospects(:new_prospect)
  end

  test "searches prospects by project title" do
    results = Prospect.search("Midnight Garden")
    assert_includes results, prospects(:new_prospect)
    assert_not_includes results, prospects(:contacted_prospect)

    results = Prospect.search("Neural")
    assert_includes results, prospects(:contacted_prospect)
    assert_not_includes results, prospects(:new_prospect)
  end

  # Stage transition tests
  test "transitions to next stage" do
    prospect = prospects(:new_prospect)

    # new -> contacted
    assert prospect.transition_to!("contacted")
    assert_equal "contacted", prospect.stage
    assert_not_nil prospect.stage_changed_at

    # contacted -> evaluating
    assert prospect.transition_to!("evaluating")
    assert_equal "evaluating", prospect.stage

    # evaluating -> negotiating
    assert prospect.transition_to!("negotiating")
    assert_equal "negotiating", prospect.stage

    # negotiating -> converted
    assert prospect.transition_to!("converted")
    assert_equal "converted", prospect.stage
  end

  test "prevents invalid stage transitions" do
    prospect = prospects(:new_prospect)

    # Cannot skip stages: new cannot go directly to negotiating
    assert_not prospect.transition_to!("negotiating")
    assert_equal "new", prospect.stage
    assert_includes prospect.errors[:stage], "cannot transition from new to negotiating"

    # Cannot go directly to converted from new
    assert_not prospect.transition_to!("converted")
    assert_equal "new", prospect.stage
  end

  test "allows transition to declined from any active stage" do
    # From new
    prospect = Prospect.new(first_name: "Test", last_name: "User", stage: "new")
    prospect.save!
    assert prospect.transition_to!("declined")
    assert_equal "declined", prospect.stage

    # From contacted
    prospect = Prospect.new(first_name: "Test", last_name: "User2", stage: "contacted")
    prospect.save!
    assert prospect.transition_to!("declined")
    assert_equal "declined", prospect.stage

    # From evaluating
    prospect = Prospect.new(first_name: "Test", last_name: "User3", stage: "evaluating")
    prospect.save!
    assert prospect.transition_to!("declined")
    assert_equal "declined", prospect.stage

    # From negotiating
    prospect = Prospect.new(first_name: "Test", last_name: "User4", stage: "negotiating")
    prospect.save!
    assert prospect.transition_to!("declined")
    assert_equal "declined", prospect.stage
  end

  test "cannot transition from converted" do
    prospect = prospects(:converted_prospect)

    assert_not prospect.transition_to!("declined")
    assert_equal "converted", prospect.stage
    assert_includes prospect.errors[:stage], "cannot transition from converted"
  end

  test "cannot transition from declined" do
    prospect = prospects(:declined_prospect)

    assert_not prospect.transition_to!("new")
    assert_equal "declined", prospect.stage
    assert_includes prospect.errors[:stage], "cannot transition from declined"
  end

  # Convert to author tests
  test "converts to author record" do
    prospect = prospects(:negotiating_prospect)

    author = prospect.convert_to_author!

    assert author.persisted?
    assert_equal prospect.first_name, author.first_name
    assert_equal prospect.last_name, author.last_name
    assert_equal prospect.email, author.email
    assert_equal prospect.phone, author.phone
    assert_equal prospect.genre_interest, author.genre_focus
    assert_equal "active", author.status

    # Prospect should be marked as converted
    prospect.reload
    assert_equal "converted", prospect.stage
  end

  test "convert to author fails if not in negotiating stage" do
    prospect = prospects(:new_prospect)

    author = prospect.convert_to_author!

    assert_nil author
    assert_includes prospect.errors[:stage], "must be in negotiating stage to convert"
    assert_equal "new", prospect.stage
  end

  test "convert to author fails if prospect is already converted" do
    prospect = prospects(:converted_prospect)

    author = prospect.convert_to_author!

    assert_nil author
    assert_includes prospect.errors[:stage], "prospect has already been converted"
  end

  # Decline tests
  test "marks as declined with reason" do
    prospect = prospects(:evaluating_prospect)

    assert prospect.decline!("Not a good fit for our list at this time.")

    prospect.reload
    assert_equal "declined", prospect.stage
    assert_equal "Not a good fit for our list at this time.", prospect.decline_reason
    assert_not_nil prospect.stage_changed_at
  end

  test "decline fails without reason" do
    prospect = prospects(:evaluating_prospect)

    assert_not prospect.decline!(nil)
    assert_equal "evaluating", prospect.stage
    assert_includes prospect.errors[:decline_reason], "is required when declining"
  end

  test "decline fails with blank reason" do
    prospect = prospects(:evaluating_prospect)

    assert_not prospect.decline!("")
    assert_equal "evaluating", prospect.stage
    assert_includes prospect.errors[:decline_reason], "is required when declining"
  end

  # Days in current stage tests
  test "calculates days in current stage" do
    prospect = prospects(:new_prospect)
    # Fixture has stage_changed_at 2 days ago
    assert_equal 2, prospect.days_in_current_stage

    prospect = prospects(:evaluating_prospect)
    # Fixture has stage_changed_at 10 days ago
    assert_equal 10, prospect.days_in_current_stage
  end

  test "returns zero days when stage_changed_at is nil" do
    prospect = Prospect.new(
      first_name: "John",
      last_name: "Doe",
      stage_changed_at: nil
    )
    assert_equal 0, prospect.days_in_current_stage
  end

  test "returns zero days when stage_changed_at is today" do
    prospect = Prospect.new(
      first_name: "John",
      last_name: "Doe",
      stage_changed_at: Time.current
    )
    assert_equal 0, prospect.days_in_current_stage
  end

  # Association tests
  test "belongs to agent" do
    prospect = prospects(:contacted_prospect)
    assert_equal agents(:simon_lipskar), prospect.agent
  end

  test "agent is optional" do
    prospect = prospects(:unassigned_prospect)
    assert_nil prospect.agent
    assert prospect.valid?
  end
end
