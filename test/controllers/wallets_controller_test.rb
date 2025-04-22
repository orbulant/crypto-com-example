require "test_helper"

class WalletsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @first_wallet = wallets(:first_user_wallet)
    @second_wallet = wallets(:second_user_wallet)
  end

  test "should deposit money" do
    initial_balance = @first_wallet.balance
    deposit_amount = 100.0

    post deposit_wallet_url(@first_wallet), params: {
      wallet: { amount: deposit_amount }
    }, as: :json

    assert_response :success
    @first_wallet.reload
    assert_equal initial_balance + deposit_amount, @first_wallet.balance
  end

  test "should withdraw money" do
    # First deposit some money
    post deposit_wallet_url(@first_wallet), params: {
      wallet: { amount: 100.0 }
    }, as: :json

    initial_balance = @first_wallet.reload.balance
    withdraw_amount = 50.0

    post withdraw_wallet_url(@first_wallet), params: {
      wallet: { amount: withdraw_amount }
    }, as: :json

    assert_response :success
    @first_wallet.reload
    assert_equal initial_balance - withdraw_amount, @first_wallet.balance
  end

  test "should not withdraw more than balance" do
    post withdraw_wallet_url(@first_wallet), params: {
      wallet: { amount: 100.0 } # Make sure this is more than the balance in the user's wallet
    }, as: :json

    assert_response :unprocessable_entity
    assert_equal({ "error" => "Insufficient funds" }, JSON.parse(@response.body))
  end
end
