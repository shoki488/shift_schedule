require 'rails_helper'

RSpec.describe "Searches", type: :request do
  let!(:user) { FactoryBot.create(:user, name: "yamada takashi") }
  let!(:shift) { FactoryBot.create(:shift, calendar: "2025-07-07") }

  before do
    sign_in user
  end
  describe "GET /search" do
    it "製作者名で検索できること" do
      get "/search", params: { query: "yamada" }
      expect(response).to have_http_status(200)
      expect(response.body).to include("yamada takashi")
    end

    it "カレンダーで検索できること" do
      get "/search", params: { range: "Shift", word: "2025-07-07", search: "partial_match" }
      expect(response).to have_http_status(200)
      expect(response.body).to include("2025-07-07")
    end

    context "検索機能の動作確認" do
      it "前方一致で検索できること" do
        get "/search", params: { query: "yamada" }
        expect(response.body).to include("yamada takashi")
      end

      it "後方一致で検索できること" do
        get "/search", params: { query: "takashi" }
        expect(response.body).to include("yamada takashi")
      end

      it "部分一致で検索できること" do
        get "/search", params: { query: "mada tak" }
        expect(response.body).to include("yamada takashi")
      end

      it "完全一致で検索できること" do
        get "/search", params: { query: "yamada takashi" }
        expect(response.body).to include("yamada takashi")
      end
    end
  end
end
