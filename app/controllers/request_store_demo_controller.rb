# Demo endpoint for inspecting RequestStore during a real HTTP request.
#
# Why not rails console?
#   RequestStore is cleared between requests by middleware. In console there is
#   no request lifecycle, so the store is empty unless you set values manually.
#
# How to try it:
#   1. Start the server:  bin/rails server
#   2. Visit:            http://localhost:3000/request_store_demo
#   3. Execution pauses at each binding.break — in the debugger, inspect:
#        RequestStore.store
#        RequestStoreContext.user_id
#        RequestStoreContext.request_path
#      Type `continue` (or `c`) to move to the next breakpoint.
#
# Request flow for this page:
#   middleware opens a fresh RequestStore hash
#     -> ApplicationController#store_request_context writes user_id + request_path
#     -> this action adds a demo flag and reads the store in the controller
#     -> Card#capture_request_context reads the same store in the model layer
#     -> middleware clears RequestStore when the response is sent
class RequestStoreDemoController < ApplicationController
  allow_unauthenticated_access only: :show

  def show
    # STEP 1 (controller): ApplicationController#store_request_context already ran.
    # The store was populated from the incoming request before this action started.
    #
    # In the debugger, try:
    #   RequestStore.store
    #   => { user_id: nil, request_path: "/request_store_demo" }  # user_id set if logged in
    binding.break # rubocop:disable Lint/Debugger

    # STEP 2 (controller): Write an extra per-request flag.
    # Any code later in this same request can read it — models, jobs enqueued
    # synchronously, service objects, etc.
    RequestStore.store[:request_store_demo] = true

    # STEP 3 (model): Trigger model code that reads RequestStore without
    # the controller passing these values as arguments.
    card = Card.new(card_number: "demo-#{Time.current.to_i}")
    card.capture_request_context

    # STEP 4 (controller): Pause again so you can compare controller vs model reads.
    # In the debugger, try:
    #   card.request_context
    #   RequestStore.store[:captured_in_model]
    binding.break # rubocop:disable Lint/Debugger

    render plain: <<~TEXT
      RequestStore demo (response also shown if you skip the debugger with `continue`)

      Raw store:              #{RequestStore.store.inspect}
      Via RequestStoreContext: user_id=#{RequestStoreContext.user_id.inspect}, path=#{RequestStoreContext.request_path.inspect}
      Captured in model:      #{RequestStore.store[:captured_in_model].inspect}

      Hit this URL again — values are new each request. After the response, middleware clears the store.
    TEXT
  end
end