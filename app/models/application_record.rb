class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # writing: the primary. reading: the replica in database.yml.
  # Rails stays on :writing until a call switches. DatabaseSelector is not enabled.
  connects_to database: { writing: :primary, reading: :replica }
end
