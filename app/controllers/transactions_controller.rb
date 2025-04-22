class TransactionsController < ApplicationController
  include BaseErrorHandling

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
    ActiveRecord::Base.transaction do # Use transaction here to ensure atomicity to ensure that all operations succeed or non of them happen (rollback)
      @user = User.find(params[:user_id])
      @sender = User.find(transaction_params[:sender_id])

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
        raise ActiveRecord::RecordInvalid.new(@sender.wallet) if new_balance < 0
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
    # Use callbacks to share common setup or constraints between actions.
    def set_transaction
      @transaction = Transaction.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def transaction_params
      params.require(:transaction).permit(:sender_id, :receiver_id, :amount)
    end
end
