class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # writing: the primary (postgresql_proxy). reading: the replica.
  # With no connected_to, the proxy sends a SELECT to :reading and a write to :writing.
  # proxy_delay is 0, so a write does not hold the next SELECT on the primary.
  # An explicit connected_to is obeyed. DatabaseSelector is not enabled.
  connects_to database: { writing: :primary, reading: :replica }
end
