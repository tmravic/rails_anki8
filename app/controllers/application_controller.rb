class ApplicationController < ActionController::Base
  # Only allow modern browsers...
  allow_browser versions: :modern

  # === Authlogic helpers ===
  helper_method :current_user_session, :current_user

  def current_user_session
    @current_user_session ||= UserSession.find
  end

  def current_user
    @current_user ||= current_user_session&.user
  end

  def require_login
    unless current_user
      redirect_to new_user_session_path, alert: "Please log in to continue."
    end
  end
end
