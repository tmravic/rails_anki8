class ApplicationController < ActionController::Base
  include Authentication

  # Enable the mobile-fu gem.
  #
  # What this does:
  # - Includes ActionController::MobileFu into this controller
  # - Registers several helper methods (is_mobile_device?, mobile_device, etc.)
  # - Adds a before_action called :set_request_format (by default)
  #
  # Passing `true` means "yes, automatically try to set the request format".
  # We will later override set_mobile_format to get more control.
  has_mobile_fu(true)

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_user

  def current_user
    @current_user ||= User.find(Current.session.user_id) if Current.session&.user_id
    # if session = Session.find_by(id: cookies.signed[:session_id])
    #   self.current_user = session.user
    # end
  end
end
