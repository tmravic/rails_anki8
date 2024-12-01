class Api::V1::ProductsController < ApplicationController
  skip_before_action :require_authentication
  # Only allow JSON requests
  before_action :ensure_json_request

  # Disable session and cookies for APIs, if necessary
  protect_from_forgery with: :null_session

  def index
    data = { message: "Hello from the API!" }
    render json: data, status: :ok
  end

  private

  def ensure_json_request
    return if request.format == :json
    render nothing: true, status: 406 # Not Acceptable
  end
end
