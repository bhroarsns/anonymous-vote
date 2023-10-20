require "test_helper"

class VotingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @voting = votings(:one)
  end

  test "should get index" do
    get votings_url
    assert_response :success
  end

  test "should get new" do
    get new_voting_url
    assert_response :success
  end

  test "should create voting" do
    assert_difference("Voting.count") do
      post votings_url, params: { voting: { choices: @voting.choices, config: @voting.config, deadline: @voting.deadline, description: @voting.description, mode: @voting.mode, title: @voting.title, user_id: @voting.user_id } }
    end

    assert_redirected_to voting_url(Voting.last)
  end

  test "should show voting" do
    get voting_url(@voting)
    assert_response :success
  end

  test "should get edit" do
    get edit_voting_url(@voting)
    assert_response :success
  end

  test "should update voting" do
    patch voting_url(@voting), params: { voting: { choices: @voting.choices, config: @voting.config, deadline: @voting.deadline, description: @voting.description, mode: @voting.mode, title: @voting.title, user_id: @voting.user_id } }
    assert_redirected_to voting_url(@voting)
  end

  test "should destroy voting" do
    assert_difference("Voting.count", -1) do
      delete voting_url(@voting)
    end

    assert_redirected_to votings_url
  end
end
