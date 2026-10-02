class ReplicaDemosController < ApplicationController
  allow_unauthenticated_access

  # ActiveRecord::Middleware::DatabaseSelector::Resolver::SEND_TO_REPLICA_DELAY
  REPLICA_DELAY = 2

  def show
    @mode = params[:mode].to_s
    @mode = "off" unless @mode.in?(%w[off selector split])
    @last_write_age = last_write_age
    @sql = []
    @error = nil
    @selector_role = nil
    record_sql { run_mode }
    @hits = Hit.order(id: :desc).limit(8)
  end

  def create
    Hit.create!(verb: "POST", note: "non-GET write, then stamp session[:last_write]")
    session[:last_write] = Time.current.to_f
    redirect_to replica_demo_path(mode: "selector")
  end

  private

    def run_mode
      case @mode
      when "off"
        @read_count = Hit.count
        @saved = Hit.create!(verb: "GET", note: "selector off")
      when "selector"
        @selector_role = recent_write? ? :writing : :reading
        ApplicationRecord.connected_to(role: @selector_role, prevent_writes: true) do
          @read_count = Hit.count
          @saved = Hit.create!(verb: "GET", note: "selector on")
        end
      when "split"
        @read_count = ApplicationRecord.connected_to(role: :reading) { Hit.count }
        @saved = ApplicationRecord.connected_to(role: :writing) do
          Hit.create!(verb: "GET", note: "read on the replica, write on the primary")
        end
      end
    rescue ActiveRecord::ReadOnlyError => error
      @error = error
    end

    def recent_write?
      @last_write_age && @last_write_age < REPLICA_DELAY
    end

    def last_write_age
      stamped = session[:last_write]
      return if stamped.blank?

      Time.current.to_f - stamped.to_f
    end

    def record_sql
      callback = lambda do |_name, _start, _finish, _id, payload|
        return if payload[:name].in?(%w[SCHEMA TRANSACTION]) || payload[:cached]

        sql = payload[:sql].to_s.squish
        return if sql.blank?

        @sql << "role=#{ApplicationRecord.current_role}  #{sql.truncate(180)}"
      end
      ActiveSupport::Notifications.subscribed(callback, "sql.active_record") { yield }
    end
end