class PagesController < ApplicationController
  def home
    ActionCable.server.broadcast("notifications", { message: "Hello from Solid Cable!" })
  end

  def live_update
    ActionCable.server.broadcast("notifications", { message: "Live update test!" })
    Thread.new do
      ActiveRecord::Base.connection_pool.with_connection do
        # .with_connection scopes the DB query to a block,
        # checking out a connection only for its duration
        # and automatically releasing it back to the pool afterward
        # preventing long-term holds even if the Ruby thread continues (during sleep 600)
        ActiveRecord::Base.connection.execute("SELECT 1")
      end
      ActiveRecord::Base.clear_active_connections!
      # clear_active_connections! forcibly clears any lingering leases tied to the current thread
      # ensuring no "dead" or orphaned connections remain after the block
      # acting as an extra safety net for incomplete cleanups
      sleep 600
    end
    respond_to do |format|
      format.html { redirect_to root_path, notice: "Live update broadcasted!" }
      format.turbo_stream # To support Turbo if you're using it
    end
  end

  def pool_stats
    stats = ActiveRecord::Base.connection_pool.stat
    Rails.logger.info("Connection Pool Stats: #{stats.inspect}")

    render json: stats
  end

  def import
    ImportJob.perform_later
  end
end
