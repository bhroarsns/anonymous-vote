require "application_system_test_case"

class BallotsTest < ApplicationSystemTestCase
  setup do
    @ballot = ballots(:one)
  end

  test "visiting the index" do
    visit ballots_url
    assert_selector "h1", text: "Ballots"
  end

  test "should create ballot" do
    visit ballots_url
    click_on "New ballot"

    fill_in "Choice", with: @ballot.choice
    fill_in "Exp", with: @ballot.exp
    fill_in "Password digest", with: @ballot.password_digest
    fill_in "Voter", with: @ballot.voter
    fill_in "Voting", with: @ballot.voting_id
    click_on "Create Ballot"

    assert_text "Ballot was successfully created"
    click_on "Back"
  end

  test "should update Ballot" do
    visit ballot_url(@ballot)
    click_on "Edit this ballot", match: :first

    fill_in "Choice", with: @ballot.choice
    fill_in "Exp", with: @ballot.exp
    fill_in "Password digest", with: @ballot.password_digest
    fill_in "Voter", with: @ballot.voter
    fill_in "Voting", with: @ballot.voting_id
    click_on "Update Ballot"

    assert_text "Ballot was successfully updated"
    click_on "Back"
  end

  test "should destroy Ballot" do
    visit ballot_url(@ballot)
    click_on "Destroy this ballot", match: :first

    assert_text "Ballot was successfully destroyed"
  end
end
