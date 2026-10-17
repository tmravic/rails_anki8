# Paperclip keeps only metadata in the database. Each attachment needs four
# columns, which add_attachment creates:
#   <name>_file_name, <name>_content_type, <name>_file_size, <name>_updated_at
# The file itself is written to disk at the model's :path.
# (tac_webschool master did the same with t.attachment, e.g. AddAttachmentFilesToIoQuestions.)
class AddAttachmentsToCards < ActiveRecord::Migration[8.0]
  def change
    add_attachment :cards, :image, :pdf
  end
end
