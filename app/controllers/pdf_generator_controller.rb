class PdfGeneratorController < ApplicationController
  require 'prawn'
  require 'prawn/table'

  def generate
    respond_to do |format|
      format.html # Optional: Render an HTML view if needed
      format.pdf do
        pdf = Prawn::Document.new
        pdf.text "Hello, this is a sample PDF generated with Prawn in Rails!"
        pdf.text "You can add more content here, like tables or images."

        # Example: Add a table
        # Use methods like text, table, image (for adding images), etc., to build content.
        pdf.table(
          [
            ["Column 1", "Column 2"],
            ["Row 1 Data", "Row 2 Data"]
          ]
        )

        # Send the PDF as a response.
        # send_data streams the PDF to the browser.
        send_data pdf.render, filename: "sample.pdf", type: "application/pdf", disposition: "inline"
        # Use disposition: "attachment" if you want to force a download instead of inline viewing.
      end
    end
  end
end
