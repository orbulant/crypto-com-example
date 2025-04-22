class TransactionsController < ApplicationController
  include BaseErrorHandling

  # POST /users/:user_id/transactions/deposit
  def transfer_to
    ActiveRecord::Base.transaction do # Use transaction here to ensure atomicity to ensure that all operations succeed or non of them happen (rollback)
      @user = User.find(params[:user_id])
      @sender = User.find(transaction_params[:sender_id])

      # Self explanatory check here
      if @user.id == @sender.id
        render json: { error: "Sender and receiver cannot be the same" }, status: :unprocessable_entity and return
      end

      @wallet = @user.wallet
      @transaction = @wallet.transactions.new(
        amount: transaction_params[:amount],
        user_id: @sender.id
      )

      # Update sender's wallet balance
      @sender.wallet.with_lock do # Use lock to prevent race conditions
        # Set a new temporary balance
        new_balance = @sender.wallet.balance - transaction_params[:amount].to_f
        # Check if sender has sufficient balance
        if new_balance < 0
          render json: { error: "Insufficient funds" }, status: :unprocessable_entity and return
        end
        # Update sender's wallet balance
        @sender.wallet.update!(balance: new_balance)
      end

      if @transaction.save
        # Update receiver's wallet balance
        @wallet.with_lock do # Use a lock here to prevent race conditions
          @wallet.update!(balance: @wallet.balance + transaction_params[:amount].to_f)
        end
        render json: @transaction, status: :created
      else
        raise ActiveRecord::Rollback # Rollback the transaction if saving fails
      end
    end
  end

  private
    # Only allow a list of trusted parameters through.
    def transaction_params
      params.require(:transaction).permit(:sender_id, :receiver_id, :amount)
    end
end
