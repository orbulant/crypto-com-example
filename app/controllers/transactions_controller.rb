class TransactionsController < ApplicationController
  before_action :set_transaction, only: %i[ show ]

  # GET /transactions
  def index
    @transactions = Transaction.all

    render json: @transactions
  end

  # GET /transactions/1
  def show
    render json: @transaction
  end

  # POST /transactions
  def create
    @transaction = Transaction.new(transaction_params)

    if @transaction.save
      render json: @transaction, status: :created, location: @transaction
    else
      render json: @transaction.errors, status: :unprocessable_entity
    end
  end

  # POST /users/:user_id/transactions/deposit
  def transfer_to
    ActiveRecord::Base.transaction do
      @user = User.find(params[:user_id])
      @sender = User.find(transaction_params[:sender_id])

      @wallet = @user.wallet
      @transaction = @wallet.transactions.new(
        amount: transaction_params[:amount],
        user_id: @sender.id
      )

      # Update sender's wallet balance
      @sender.wallet.with_lock do
        new_balance = @sender.wallet.balance - transaction_params[:amount].to_f
        raise ActiveRecord::RecordInvalid if new_balance < 0
        @sender.wallet.update!(balance: new_balance)
      end

      if @transaction.save
        # Update sender's wallet balance
        @wallet.with_lock do # Prevent a race condition here when updating the wallet balance
          @wallet.update!(balance: @wallet.balance + transaction_params[:amount].to_f)
        end
        render json: @transaction, status: :created
      else
        raise ActiveRecord::Rollback
      end
    end

  rescue ActiveRecord::RecordInvalid
    render json: { error: "Insufficient funds" }, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotFound
    render json: { error: "User or sender not found" }, status: :not_found
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transaction
      @transaction = Transaction.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def transaction_params
      params.require(:transaction).permit(:sender_id, :receiver_id, :amount)
    end
end
