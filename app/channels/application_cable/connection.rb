module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      reject_unauthorized_connection unless current_user
    end

    private

    def find_verified_user
      # Authlogic stores the persistence token in the signed cookie
      token = cookies.signed[:user_credentials]
      User.find_by(persistence_token: token) if token
    end
  end
end
