require "test_helper"

class TransactionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @first_user = users(:first_user)
    @second_user = users(:second_user)
    @first_wallet = wallets(:first_user_wallet)
    @second_wallet = wallets(:second_user_wallet)
  end

  test "should transfer money between users" do
    # First deposit money to first user's wallet
    post deposit_wallet_url(@first_wallet), params: {
      wallet: { amount: 100.0 }
    }, as: :json

    initial_sender_balance = @first_wallet.reload.balance
    initial_receiver_balance = @second_wallet.reload.balance
    transfer_amount = 50.0

    post transfer_to_user_transactions_url(@second_user), params: {
      transaction: {
        amount: transfer_amount,
        sender_id: @first_user.id
      }
    }, as: :json

    assert_response :created
    
    @first_wallet.reload
    @second_wallet.reload
    
    assert_equal initial_sender_balance - transfer_amount, @first_wallet.balance
    assert_equal initial_receiver_balance + transfer_amount, @second_wallet.balance
  end

  test "should not transfer with insufficient funds" do
    post transfer_to_user_transactions_url(@second_user), params: {
      transaction: {
        amount: 1000.0,
        sender_id: @first_user.id
      }
    }, as: :json

    assert_response :unprocessable_entity
    assert_equal({ "error" => "Insufficient funds" }, JSON.parse(@response.body))
  end

  test "should not transfer to self" do
    post transfer_to_user_transactions_url(@first_user), params: {
      transaction: {
        amount: 50.0,
        sender_id: @first_user.id
      }
    }, as: :json

    assert_response :unprocessable_entity
    assert_equal({ "error" => "Sender and receiver cannot be the same" }, JSON.parse(@response.body))
  end
end
