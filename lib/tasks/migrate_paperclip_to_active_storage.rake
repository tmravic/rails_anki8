# Mini copy of tac_webschool's lib/tasks/migrate_paperclip_to_active_storage.rake.
# That task walks every converted model. This one only copies Card#image and Card#pdf.
#
# Card still uses Paperclip (has_attached_file), so card.image is not an
# Active Storage attachment and has no .attach. The full task calls .attach
# only after a model has switched to has_one_attached. This copy writes the
# Active Storage rows itself and leaves the Paperclip columns and files in place.
#
# Only the original image is copied. small_ and thumb_ stay as Paperclip's
# files. Active Storage keeps one blob and makes other sizes when something
# asks for a variant.
#
#   bin/rails paperclip:migrate_cards
#
# Legend: . = copied, = = already in Active Storage, S = file missing on disk
namespace :paperclip do
  desc "Copy Card Paperclip files into Active Storage. Paperclip columns and files stay."
  task migrate_cards: :environment do
    # tac_webschool reads the same files from an EFS mount. Here they live in the app tree.
    legacy_root = ENV.fetch("PAPERCLIP_LEGACY_ROOT", Rails.root.to_s)

    puts "=== Copying Card attachments into Active Storage ==="

    Card.find_each do |card|
      [ :image, :pdf ].each do |attachment_name|
        file_name = card.public_send("#{attachment_name}_file_name")
        next if file_name.blank?

        if ActiveStorage::Attachment.exists?(record: card, name: attachment_name.to_s)
          print "="
          next
        end

        old_path =
          if attachment_name == :image
            # public/image_assets/:class/:id/:style_:basename.:extension
            File.join(legacy_root, "public/image_assets/cards/#{card.id}/original_#{file_name}")
          else
            # assets/:class/:id_partition/:basename.:extension
            id_partition = card.id.to_s.rjust(9, "0").scan(/.{3}/).join("/")
            File.join(legacy_root, "assets/cards/#{id_partition}/#{file_name}")
          end

        begin
          File.open(old_path, "rb") do |io|
            # ActiveStorage::Attachment belongs_to :record, touch: true.
            # Copying a file is not an edit of the card.
            ActiveRecord::Base.no_touching do
              blob = ActiveStorage::Blob.create_and_upload!(
                io: io,
                filename: file_name,
                content_type: card.public_send("#{attachment_name}_content_type")
              )
              ActiveStorage::Attachment.create!(name: attachment_name.to_s, record: card, blob: blob)
            end
          end
          print "."
        rescue Errno::ENOENT
          print "S"
        end
      end
    end

    puts
    puts "Done. Paperclip columns and files were left in place."
    puts "Legend: . = copied, = = already in Active Storage (skipped), S = file missing on disk (skipped)"
  end
end
