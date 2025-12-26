# create_table "cards", force: :cascade do |t|
#   t.bigint "user_id", null: false
#   t.string "card_number"
#   t.datetime "created_at", null: false
#   t.datetime "updated_at", null: false
#   t.index ["user_id"], name: "index_cards_on_user_id"
# end

class Card < ApplicationRecord
  belongs_to :user, optional: true
end
