class Api::V1::ApiBaseController < ApplicationController
  skip_before_action :require_authentication
  # Only allow JSON requests
  before_action :ensure_json_request

  # Disable session and cookies for APIs, if necessary
  protect_from_forgery with: :null_session

  private

  def ensure_json_request
    return if request.format.json?
    render json: { error: "Only JSON format is accepted" }, status: :not_acceptable # 406
  end
end
