module BaseErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError, with: :handle_standard_error
    rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :handle_record_invalid
  end

  private

  def handle_standard_error(exception)
    render json: { error: exception.message }, status: :internal_server_error
  end

  def handle_record_not_found(exception)
    render json: { error: exception.message }, status: :not_found
  end

  def handle_record_invalid(exception)
    render json: { error: exception.message }, status: :unprocessable_entity
  end
end
