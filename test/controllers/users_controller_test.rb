require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @first_user = users(:first_user)
    @second_user = users(:second_user)
    @first_wallet = wallets(:first_user_wallet)
    @second_wallet = wallets(:second_user_wallet)
  end

  test "should get index" do
    get users_url, as: :json
    assert_response :success
    assert_equal User.count, JSON.parse(@response.body).length
  end

  test "should create user" do
    assert_difference([ "User.count", "Wallet.count" ]) do
      post users_url, params: {
        user: { email: "test@example.com", name: "Test User" }
      }, as: :json
    end

    assert_response :created
    user = User.last
    assert_not_nil user.wallet
    assert_equal 0.0, user.wallet.balance
  end

  test "should show user" do
    get user_url(@first_user), as: :json
    assert_response :success
    response_body = JSON.parse(@response.body)
    assert_equal @first_user.email, response_body["email"]
  end

  test "should update user" do
    patch user_url(@first_user), params: {
      user: { name: "Updated Name" }
    }, as: :json
    assert_response :success
    @first_user.reload
    assert_equal "Updated Name", @first_user.name
  end

  test "should destroy user" do
    assert_difference("User.count", -1) do
      delete user_url(@first_user), as: :json
    end
    assert_response :no_content
  end

  test "should show balance" do
    post show_balance_user_url(@first_user), as: :json
    assert_response :success
    response_data = JSON.parse(@response.body)
    assert_equal @first_wallet.balance.to_f, response_data["balance"].to_f
  end

  test "should show transactions" do
    post show_transactions_user_url(@first_user), as: :json
    assert_response :success
    assert_kind_of Array, JSON.parse(@response.body)
  end
end
