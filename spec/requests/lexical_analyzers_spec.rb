require 'rails_helper'

RSpec.describe "LexicalAnalyzers", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/lexical_analyzers/index"
      expect(response).to have_http_status(:success)
    end
  end

end
