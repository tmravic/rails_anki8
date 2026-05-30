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

  # Use a dynamic layout.
  # The company application chooses different layouts depending on whether
  # the user is on a mobile device and which part of the site they are in.
  layout :select_layout

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_user

  def current_user
    @current_user ||= User.find(Current.session.user_id) if Current.session&.user_id
    # if session = Session.find_by(id: cookies.signed[:session_id])
    #   self.current_user = session.user
    # end
  end

  # --- Mobile view switching (company pattern) ---

  # This before_action reads the pc_style parameter and sets a cookie.
  # The custom is_mobile_device? in custom_mobilefu.rb reads this cookie.
  before_action :set_mobile_view

  # after_action is used in the real app to clean up after a special
  # diagnostic page. We keep it here for fidelity with the company code.
  after_action :clear_mobile_view

  helper_method :use_mobile_view?

  # Handles ?pc_style=0 and ?pc_style=1 parameters.
  # This is how users in the real application can force mobile or desktop
  # rendering regardless of their actual device.
  def set_mobile_view
    if params[:pc_style] == "1"
      cookies[:pc_style] = "1"
    elsif params[:pc_style] == "0"
      cookies[:pc_style] = "0"
    end

    session[:mobile_view] = use_mobile_view?
  end

  def clear_mobile_view
    # No-op in this simplified version.
    # The real application uses this to restore state after visiting
    # a special "about environment" diagnostic page.
  end

  # The central decision method used throughout the company application.
  def use_mobile_view?
    pc_style_str = cookies[:pc_style].to_s
    pc_style     = (pc_style_str == "1")

    (is_mobile_device? || is_tablet_device?) && !pc_style
  end

  # This is the method referenced by `layout :select_layout` above.
  #
  # In the real company application this returns "mobile" or "user"
  # (or sometimes "user_simply" for the login screen).
  #
  # For now we always return "application" so we don't break anything.
  # We will create proper mobile and user layouts in later steps.
  def select_layout
    "application"
  end

  # Override the method that decides whether to switch the request format
  # to :mobile.
  #
  # The default implementation in mobile-fu is good, but the company version
  # also treats tablets as mobile and has better nil safety.
  def set_mobile_format
    if !mobile_exempt? && is_mobile_device? && !request.xhr?
      request.format = :mobile unless session[:mobile_view] == false
      session[:mobile_view] = true if session[:mobile_view].nil?
    elsif !mobile_exempt? && is_tablet_device? && !request.xhr?
      request.format = :mobile unless session[:mobile_view] == false
      session[:mobile_view] = true if session[:mobile_view].nil?
    end
  end

  # Defensive version of the method the gem uses internally.
  # The original gem could crash with nil.to_sym on some actions.
  def mobile_exempt?
    return false if params[:action].nil?
    self.class.instance_variable_get("@mobile_exempt_actions").try(:include?, params[:action].to_sym)
  end
end
