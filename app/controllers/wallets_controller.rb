class WalletsController < ApplicationController
  before_action :set_wallet, only: %i[ deposit ]

  # POST /wallets/:id/deposit
  def deposit
    ActiveRecord::Base.transaction do
      @wallet.with_lock do
        new_balance = @wallet.balance + wallet_params[:amount].to_f
        if @wallet.update(balance: new_balance)
          render json: @wallet, status: :ok
        else
          render json: @wallet.errors, status: :unprocessable_entity
        end
      end
    end
  rescue ActiveRecord::RecordInvalid
    render json: { error: "Invalid transaction" }, status: :unprocessable_entity
  end

  # POST /wallets/:id/withdraw
  def withdraw
    ActiveRecord::Base.transaction do
      @wallet.with_lock do
        new_balance = @wallet.balance - wallet_params[:amount].to_f

        if new_balance < 0
          render json: { error: "Insufficient funds" }, status: :unprocessable_entity
          return
        end

        if @wallet.update(balance: new_balance)
          render json: @wallet, status: :ok
        else
          render json: @wallet.errors, status: :unprocessable_entity
        end
      end
    end
  rescue ActiveRecord::RecordInvalid
    render json: { error: "Invalid transaction" }, status: :unprocessable_entity
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_wallet
      @wallet = Wallet.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def wallet_params
      params.require(:wallet).permit(:amount)
    end
end
