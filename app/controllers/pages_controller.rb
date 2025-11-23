class PagesController < ApplicationController
  def home
    ActionCable.server.broadcast("notifications", { message: "Hello from Solid Cable!" })
  end

  def live_update
    ActionCable.server.broadcast("notifications", { message: "Live update test!" })
    Thread.new do
      # This checks out a connection and leases it to this thread
      ActiveRecord::Base.connection.execute("SELECT 1")
      # Hold the thread (and leased connection) for 10 minutes
      sleep 600
      # The sleep 600 keeps the thread alive and running in Ruby for 10 minutes,
      # so the lease isn't released until the thread fully terminates (exits)
      # even though the query itself completes on the DB side quickly.
      # During this time, the connection appears 'busy'
      # (or potentially transitions to 'dead' if cleanup fails post-termination)
      # in the app's pool stats, preventing reuse by other requests/threads.
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
