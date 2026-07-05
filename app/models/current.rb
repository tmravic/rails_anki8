class Current < ActiveSupport::CurrentAttributes
  attribute :session
  # Look at Authentication#resume_session
  #  Current.session ||= Session.find_by(id: cookies.signed[:session_id])

  # Rails stores Current.session in thread-local storage
  # and lets you write to it with Current.session=
  # which clears when the request ends.

  delegate :user, to: :session, allow_nil: true
  # Allows a shortcut Current.user instead of
  # Current.session.user
end
