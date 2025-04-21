class ApplicationController < ActionController::API
  def destroy_everything
    ActiveRecord::Base.transaction do
      Transaction.destroy_all
      Wallet.destroy_all
      User.destroy_all

      render json: { message: "All records deleted successfully!" }, status: :ok
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
