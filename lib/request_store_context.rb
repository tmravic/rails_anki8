# Thin wrapper around the request_store gem.
#
# RequestStore.store is a Hash-like object scoped to the current HTTP request.
# The gem's middleware creates an empty store at request start and clears it at
# request end, so values never leak into the next request or another thread.
#
# You can also use the gem directly:
#   RequestStore.store[:key] = value
#   RequestStore[:key]                     # shorthand
module RequestStoreContext
  def self.user_id=(id)
    RequestStore.store[:user_id] = id
  end

  def self.user_id
    RequestStore.store[:user_id]
  end

  def self.request_path=(path)
    RequestStore.store[:request_path] = path
  end

  def self.request_path
    RequestStore.store[:request_path]
  end
end