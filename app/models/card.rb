# create_table "cards", force: :cascade do |t|
#   t.bigint "user_id", null: false
#   t.string "card_number"
#   t.datetime "created_at", null: false
#   t.datetime "updated_at", null: false
#   t.string "image_file_name"
#   t.string "image_content_type"
#   t.bigint "image_file_size"
#   t.datetime "image_updated_at"
#   t.string "pdf_file_name"
#   t.string "pdf_content_type"
#   t.bigint "pdf_file_size"
#   t.datetime "pdf_updated_at"
#   t.index ["user_id"], name: "index_cards_on_user_id"
# end

class Card < ApplicationRecord
  belongs_to :user, optional: true

  # Paperclip, copied from how tac_webschool master (Rails 5.1) used it.
  # has_attached_file reads and writes the image_* / pdf_* columns and puts the
  # file on disk at :path. It gives the model:
  #   card.image = File.open("cat.png")  # assign; the file is written on save
  #   card.image?                        # true when image_file_name is set
  #   card.image.url(:thumb)             # :url with :style filled in
  #   card.image.path(:original)         # :path with :style filled in
  #   card.image = nil; card.save        # clears the columns and deletes the files

  # Like AdminMessage#image on master: stored under public/, so the web server
  # serves it straight from :url. On save Paperclip runs ImageMagick once per
  # style and writes original_, small_ and thumb_ copies next to each other.
  has_attached_file :image,
                    url:    "/image_assets/:class/:id/:style_:basename.:extension",
                    path:   ":rails_root/public/image_assets/:class/:id/:style_:basename.:extension",
                    styles: { small: "60x60#", thumb: "130x150#" }
  validates_attachment :image, content_type: { content_type: %w[image/jpeg image/png image/gif] }

  # Like Inform#pdf and ChairPdf#file1 on master: stored outside public/, so
  # there is no direct URL; a controller would send_file(card.pdf.path).
  # :id_partition turns id 123 into 000/000/123 so no folder gets too big.
  # No styles, so only the uploaded file is kept, under its own name.
  has_attached_file :pdf,
                    url:  "/:class/:id/:style.:extension",
                    path: ":rails_root/assets/:class/:id_partition/:basename.:extension"
  validates_attachment :pdf, content_type: { content_type: %w[application/pdf] }
end
