class ApplicationController < ActionController::Base
  include CanCan::ControllerAdditions
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_user

  def current_user
    @current_user ||= User.find(Current.session.user_id) if Current.session&.user_id
    # if session = Session.find_by(id: cookies.signed[:session_id])
    #   self.current_user = session.user
    # end
  end

  # Error handling when a user tries something they're not allowed to do
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, alert: exception.message
  end

  # This is what CanCanCan uses internally
  def current_ability
    @current_ability ||= Ability.new(current_user)
  end
end
