require "application_system_test_case"

class VotingsTest < ApplicationSystemTestCase
  setup do
    @voting = votings(:one)
  end

  test "visiting the index" do
    visit votings_url
    assert_selector "h1", text: "Votings"
  end

  test "should create voting" do
    visit votings_url
    click_on "New voting"

    fill_in "Choices", with: @voting.choices
    fill_in "Config", with: @voting.config
    fill_in "Deadline", with: @voting.deadline
    fill_in "Description", with: @voting.description
    fill_in "Mode", with: @voting.mode
    fill_in "Title", with: @voting.title
    fill_in "User", with: @voting.user_id
    click_on "Create Voting"

    assert_text "Voting was successfully created"
    click_on "Back"
  end

  test "should update Voting" do
    visit voting_url(@voting)
    click_on "Edit this voting", match: :first

    fill_in "Choices", with: @voting.choices
    fill_in "Config", with: @voting.config
    fill_in "Deadline", with: @voting.deadline
    fill_in "Description", with: @voting.description
    fill_in "Mode", with: @voting.mode
    fill_in "Title", with: @voting.title
    fill_in "User", with: @voting.user_id
    click_on "Update Voting"

    assert_text "Voting was successfully updated"
    click_on "Back"
  end

  test "should destroy Voting" do
    visit voting_url(@voting)
    click_on "Destroy this voting", match: :first

    assert_text "Voting was successfully destroyed"
  end
end
