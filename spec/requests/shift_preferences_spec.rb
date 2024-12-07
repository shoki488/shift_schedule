require 'rails_helper'

RSpec.describe "ShiftPreferences", type: :request do
  let(:leader) { FactoryBot.create(:user, :leader) }

  before do
    sign_in leader
  end

  it "リーダーのみシフト希望一覧が表示されること" do
    get "/shift_preferences"
    expect(response).to have_http_status(200)
    expect(response.body).to include("従業員シフト希望一覧")
    expect(response.body).to include(leader.name)
  end
end
