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

        pdf.move_down 50

        # Add the shipper box example
        # Adjusted y to pdf.cursor (344.5119 here) for dynamic positioning
        pdf.bounding_box([26, pdf.cursor], width: 271, height: 77) do
          pdf.font('Helvetica', size: 8) # Using built-in font; replace with 'NotoSans' if fonts are set up

          # Precompute min heights (add cell padding buffer)
          # This calculates the minimum height needed for each row's text using pdf.height_of,
          # which measures the rendered height of the string at the given font size.
          # We add padding (e.g., +8 for ~4 top/bottom) to ensure space around the text and prevent tight fitting.
          label_text = "Shipper"
          # pdf.height_of(label_text, size: 8) == 9.248
          label_min_height = pdf.height_of(label_text, size: 8) + 8
          # +top/bottom padding ~4 each makes label_min_height == 17.2479

          name_text = "HBL Shipper Name (Lookup D)"
          name_min_height = pdf.height_of(name_text, size: 8) + 8
          # Same as above, name_min_height == 17.2479

          # Small buffer to prevent overflow
          # This ensures the total row heights fit within the bounding box height by subtractng a small buffer (e.g., -2)
          # to account for any minor rendering discrepencies or rounding errors.
          info_min_height = pdf.bounds.height - label_min_height - name_min_height - 2
          # pdf.bounds.height == 77, height set for the bounding box
          # 77 - 17.2479 - 17.2479 -2 (for a bit of padding)
          # info_min_height == 40.504

          # Define the table data as a 2D array: each sub-array is a row with one cell (single column table).
          table_data = [
            [label_text],
            [name_text],
            ["HBL Shipper Info"] # truncates if multi-line exceeds remaining box space
          ]

          # Set column widths to match the full available width of the bounding box,
          # ensuring the table spans the entire width without margins.
          available_width = pdf.bounds.width # 271
          col_widths = [available_width] # [271]

          # Ensure starting exactly at box top
          # pdf.move_cursor_to resets the cursor to the top of the current bounding box,
          # guaranteeing the table starts right at the top edge without unwanted spacing.
          pdf.move_cursor_to pdf.bounds.top # 77.0

          # Create the table with the data and configurations.
          # pdf.table handles layout, rendering cells in a grid. Here it's a 3-row, 1-column table
          # acting like stacked "rows" with custom backgrounds, mimicking nested boxes but with less code
          pdf.table(table_data, column_widths: col_widths) do |table|
            # Access and style the table's cells globally:
            table.cells.borders = [] # Remove all cell borders for a clean, borderless look
            table.cells.padding = [4, 3] # Set padding: [top/bottom, left/right] for space inside cells
            table.cells.align = :left # Horizontal text alignment within cells
            table.cells.valign = :top # Vertical text alignment (stick to top of cell)
            table.cells.overflow = :truncate # Clip text if it exceeds cell height instead of expanding or erroring

            # Row-specific styles:
            # table.row(N) targets individual rows (0-based index) for custom backgrounds and fixed heights
            # Background colors use hex codes; heights use precomputed mins to control exact sizing.
            table.row(0).background_color = 'add8e6' # Blue for label row
            table.row(0).height = label_min_height # Fixed to min height (prevents auto-expansion)
            table.row(1).background_color = '90ee90' # Green for name row
            table.row(1).height = name_min_height # Fixed min
            table.row(2).background_color = 'ffb6c1' # Red for info row, fixed to remaining space
            table.row(2).height = info_min_height # Ensures it fills the rest without overflow
          end
        end

        # Send the PDF as a response.
        # send_data streams the PDF to the browser.
        send_data pdf.render, filename: "sample.pdf", type: "application/pdf", disposition: "inline"
        # Use disposition: "attachment" if you want to force a download instead of inline viewing.
      end
    end
  end
end
