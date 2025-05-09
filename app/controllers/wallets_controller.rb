class WalletsController < ApplicationController
  include BaseErrorHandling

  before_action :set_wallet, only: %i[ deposit withdraw ]

  # POST /wallets/:id/deposit
  def deposit
    ActiveRecord::Base.transaction do # Use transaction here to ensure atomicity to ensure that all operations succeed or none of them happen (rollback)
      @wallet.with_lock do
        new_balance = @wallet.balance + wallet_params[:amount].to_f
        if @wallet.update(balance: new_balance)
          render json: @wallet, status: :ok
        else
          render json: @wallet.errors, status: :unprocessable_entity
        end
      end
    end
  end

  # POST /wallets/:id/withdraw
  def withdraw
    ActiveRecord::Base.transaction do # Use transaction here to ensure atomicity to ensure that all operations succeed or none of them happen (rollback)
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
