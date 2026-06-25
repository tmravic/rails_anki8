# create_table "cards", force: :cascade do |t|
#   t.bigint "user_id", null: false
#   t.string "card_number"
#   t.datetime "created_at", null: false
#   t.datetime "updated_at", null: false
#   t.index ["user_id"], name: "index_cards_on_user_id"
# end

class Card < ApplicationRecord
  belongs_to :user, optional: true

  # Read per-request data that ApplicationController stored earlier in the
  # same HTTP request — no need to pass user_id/path into this method.
  def request_context
    {
      user_id: RequestStoreContext.user_id,
      request_path: RequestStoreContext.request_path
    }
  end

  # Called from RequestStoreDemoController to show the model layer reading
  # the same store the controller wrote to moments ago.
  def capture_request_context
    return unless RequestStore.store[:request_store_demo]

    snapshot = request_context.merge(captured_at: Time.current)
    RequestStore.store[:captured_in_model] = snapshot

    # Pause in the model layer — note user_id/path match what you saw in the controller.
    # In the debugger: RequestStore.store
    binding.break # rubocop:disable Lint/Debugger

    snapshot
  end
end
