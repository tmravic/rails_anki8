class ReplicaDemosController < ApplicationController
  allow_unauthenticated_access

  # ActiveRecord::Middleware::DatabaseSelector::Resolver::SEND_TO_REPLICA_DELAY
  REPLICA_DELAY = 2
  MODES = %w[off selector split before_action callback].freeze
  READ_ONLY_MODES = %w[selector before_action callback].freeze

  # Declared selector first, then the recorder. prepend puts the recorder
  # outside, so it sees every query. The selector wraps the before_actions.
  prepend_around_action :simulate_database_selector
  prepend_around_action :record_sql
  before_action :prepare_demo
  before_action :write_during_before_action, if: -> { @mode == "before_action" }
  rescue_from ActiveRecord::ReadOnlyError, with: :render_read_only

  def show
    run_mode
    @hits = Hit.order(id: :desc).limit(8)
  end

  def create
    Hit.create!(verb: "POST", note: "non-GET write, then stamp session[:last_write]")
    session[:last_write] = Time.current.to_f
    redirect_to replica_demo_path(mode: "selector")
  end

  private

    def prepare_demo
      @mode = params[:mode].to_s
      @mode = "off" unless @mode.in?(MODES)
      @last_write_age = last_write_age
      @error = nil
      @saved = nil
      @read_count = nil
      @sql ||= []
    end

    # Runs on a GET, before the action. The action itself only counts rows.
    def write_during_before_action
      Hit.create!(verb: "GET", note: "before_action write")
    end

    def simulate_database_selector
      seed_probe
      unless read_only_request?
        yield
        return
      end

      @last_write_age = last_write_age
      @selector_role = recent_write? ? :writing : :reading
      ApplicationRecord.connected_to(role: @selector_role, prevent_writes: true) { yield }
    end

    def read_only_request?
      params[:mode].to_s.in?(READ_ONLY_MODES)
    end

    def seed_probe
      return unless params[:mode].to_s == "callback"
      return if Probe.exists?

      Probe.create!(source: "seed")
    end

    def run_mode
      case @mode
      when "off"
        @read_count = Hit.count
        @saved = Hit.create!(verb: "GET", note: "selector off")
      when "selector"
        @read_count = Hit.count
        @saved = Hit.create!(verb: "GET", note: "selector on")
      when "split"
        @read_count = ApplicationRecord.connected_to(role: :reading) { Hit.count }
        @saved = ApplicationRecord.connected_to(role: :writing) do
          Hit.create!(verb: "GET", note: "read on the replica, write on the primary")
        end
      when "before_action"
        @read_count = Hit.count
      when "callback"
        @read_count = Probe.count
        Thread.current[:probe_stamp] = true
        Probe.order(:id).first
      end
    ensure
      Thread.current[:probe_stamp] = false
    end

    def render_read_only(error)
      @error = error
      @hits = Hit.order(id: :desc).limit(8)
      @sql ||= []
      render :show
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
      @sql = []
      callback = lambda do |_name, _start, _finish, _id, payload|
        return if payload[:name].in?(%w[SCHEMA TRANSACTION]) || payload[:cached]

        sql = payload[:sql].to_s.squish
        return if sql.blank?

        @sql << "role=#{ApplicationRecord.current_role}  #{sql.truncate(180)}"
      end
      ActiveSupport::Notifications.subscribed(callback, "sql.active_record") { yield }
    end
end