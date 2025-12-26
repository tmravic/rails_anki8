#   create_table "products", force: :cascade do |t|
#     t.string "name"
#     t.string "sku"
#     t.float "price"
#     t.boolean "active", default: false
#     t.bigint "category_id", null: false
#     t.datetime "created_at", null: false
#     t.datetime "updated_at", null: false
#     t.index ["category_id"], name: "index_products_on_category_id"
#   end

class Product < ApplicationRecord
  belongs_to :category

  scope :active, -> { joins(:category).where(active: true).where("categories.active = ?", true) }
  scope :search, ->(query) { where("name ilike :query OR sku ilike :query", query: "%#{query}%") }

  def self.above_price(price)
    where("price >= ?", price)
  end

  def self.below_price(price)
    where("price <= ?", price)
  end
end
