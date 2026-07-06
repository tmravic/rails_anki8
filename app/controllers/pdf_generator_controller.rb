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

        # This creates a contained area on the page for content, with its own coordinate system.
        pdf.bounding_box([100, pdf.cursor - 50], width: 300, height: 200) do
          # Position it below existing content using pdf.cursor for dynamic y-positioning

          # Set the fill color to light blue using a hex code.
          pdf.fill_color 'add8e6'

          # Fill a rectangle that covers the entire bounding box with the current fill color.
          # pdf.bounds provides the dimensions of the current context (here, the bounding box).
          # IMPORTANT: Start at upper-left [left, top] since fill_rectangle extends downward from there.
          pdf.fill_rectangle [pdf.bounds.left, pdf.bounds.top], pdf.bounds.width, pdf.bounds.height

          # Reset fill color to black for text (optional, but good practice to avoid coloring other elements).
          pdf.fill_color '000000'

          # Add some simple text inside the bounding box.
          pdf.text "Cursor position: #{pdf.cursor}"
          # Text starts at the current cursor position (initially at pdf.bounds.top, or the height of the box).
          pdf.text "This is text inside the light blue bounding box."

          # Move down a bit by adjusting the cursor.
          # pdf.cursor gives the current y-position from the top of the bounding box.
          # Here, we move down 20 points from the current cursor.
          pdf.move_down 20

          pdf.text "Cursor position after moving down: #{pdf.cursor}"

          # Optionally, stroke the bounds to outline the box in black (for visibility).
          # pdf.stroke_bounds draws the outline of the current bounding box.
          pdf.stroke_bounds
        end

        # Send the PDF as a response.
        # send_data streams the PDF to the browser.
        send_data pdf.render, filename: "sample.pdf", type: "application/pdf", disposition: "inline"
        # Use disposition: "attachment" if you want to force a download instead of inline viewing.
      end
    end
  end
end
