class Probe < ApplicationRecord
  # A load looks like a read. This callback writes anyway.
  after_find :count_lookup

  private

    def count_lookup
      return unless Thread.current[:probe_stamp]

      update_column(:lookups, lookups + 1)
    end
end