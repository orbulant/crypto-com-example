class UsersController < ApplicationController
  include BaseErrorHandling

  before_action :set_user, only: %i[ show update destroy ]

  # GET /users
  def index
    @users = User.all

    render json: @users
  end

  # GET /users/1
  def show
    render json: @user.as_json
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      @wallet = @user.create_wallet(name: "Default Wallet", balance: 0.0)

      if @wallet.persisted?
        render json: @user, status: :created, location: @user
      else
        render json: @wallet.errors, status: :unprocessable_entity and return
      end
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy!
  end

  # POST /users/:id/show_balance
  def show_balance
    @user = User.find(params[:id])
    @wallet = @user.wallet

    if @wallet
      render json: { balance: @wallet.balance }
    else
      render json: { error: "Wallet not found" }, status: :not_found
    end
  end

  # POST /users/:id/show_transactions
  def show_transactions
    @user = User.find(params[:id])
    @transactions = @user.wallet.transactions

    if @transactions
      render json: @transactions
    else
      render json: { error: "No transactions found" }, status: :not_found
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(:email, :name)
  end
end
