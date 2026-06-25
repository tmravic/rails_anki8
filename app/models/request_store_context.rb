# Thin wrapper around RequestStore for per-request context.
# ApplicationController writes values here; models/services read them later
# in the same HTTP request without threading arguments through every call.
module RequestStoreContext
  class << self
    def user_id
      RequestStore.store[:user_id]
    end

    def user_id=(value)
      RequestStore.store[:user_id] = value
    end

    def request_path
      RequestStore.store[:request_path]
    end

    def request_path=(value)
      RequestStore.store[:request_path] = value
    end
  end
end
