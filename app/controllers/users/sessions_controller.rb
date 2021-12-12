class Users::SessionsController < Devise::SessionsController
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    if current_user
      render json: { message: 'You are logged in.' }, status: :ok
    else
      render json: { message: 'Sorry, you must be logged in to do this.'}, status: :unauthorized
    end
  end

  def respond_to_on_destroy
    if current_user
      return log_out_success
    else
      return log_out_failure
    end
  end

  def log_out_success
    render json: { message: "You are logged out." }, status: :ok
  end

  def log_out_failure
    render json: { message: "Hmm nothing happened."}, status: :unauthorized
  end
end