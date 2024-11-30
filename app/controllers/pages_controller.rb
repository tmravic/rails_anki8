class PagesController < ApplicationController
  def home
    ActionCable.server.broadcast("notifications", { message: "Hello from Solid Cable!" })
  end

  def live_update
    ActionCable.server.broadcast("notifications", { message: "Live update test!" })
    respond_to do |format|
      format.html { redirect_to root_path, notice: "Live update broadcasted!" }
      format.turbo_stream # To support Turbo if you're using it
    end
  end

  def import
    ImportJob.perform_later
  end
end
