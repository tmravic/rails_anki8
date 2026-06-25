class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :store_request_context

  helper_method :current_user

  def current_user
    @current_user ||= User.find(Current.session.user_id) if Current.session&.user_id
    # if session = Session.find_by(id: cookies.signed[:session_id])
    #   self.current_user = session.user
    # end
  end

  private

  # Runs on every request before the action. Writes into RequestStore so any
  # code in this request (models, services, etc.) can read context without
  # threading arguments through every call.
  def store_request_context
    RequestStoreContext.user_id = Current.user&.id
    RequestStoreContext.request_path = request.path
    # After this runs, RequestStore.store holds something like:
    #   { user_id: 1, request_path: "/cards/new" }
    # Middleware clears the entire hash when the HTTP response finishes.
  end
end
