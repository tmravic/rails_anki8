require 'rails_helper'

RSpec.describe "PdfGenerators", type: :request do
  describe "GET /generate" do
    it "returns http success" do
      get "/pdf_generator/generate"
      expect(response).to have_http_status(:success)
    end
  end

end
