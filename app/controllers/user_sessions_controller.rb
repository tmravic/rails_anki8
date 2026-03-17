class UserSessionsController < ApplicationController
  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(user_session_params.to_h.symbolize_keys)

    if @user_session.save
      redirect_to root_path, notice: "Logged in successfully!"
    else
      flash.now[:alert] = @user_session.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    current_user_session&.destroy
    redirect_to new_user_session_path, notice: "Logged out successfully!"
  end

  private

  def user_session_params
    params.require(:user_session).permit(:email_address, :password, :remember_me)
  end
end