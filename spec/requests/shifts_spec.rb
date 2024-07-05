require 'rails_helper'
require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true)
RSpec.describe "シフト作成", type: :request do
  describe "POST /shifts" do
    let(:api_key) { 'test_openai_api_key' }

    before do
      allow(ENV).to receive(:fetch).with('OPENAI_ACCESS_KEY').and_return(api_key)

      @user1 = FactoryBot.create(:user, name: 'yamada', classification: 'リーダー', shift_type: '固定シフト', email: 'yamada@example.com', password: 'password', password_confirmation: 'password')
      @user2 = FactoryBot.create(:user, name: 'tanaka', classification: '社員', shift_type: '早番', email: 'tanaka@example.com', password: 'password', password_confirmation: 'password')
      @user3 = FactoryBot.create(:user, name: 'sato', classification: '社員', shift_type: '遅番', email: 'sato@example.com', password: 'password', password_confirmation: 'password')
      @user4 = FactoryBot.create(:user, name: 'matuda', classification: 'パート・アルバイト', start_time: '10:00', end_time: '15:00', email: 'matuda@example.com',
                                        password: 'password',
                                        password_confirmation: 'password')
    end

    context "リクエストが成功した場合" do
      it "シフトが正常に作成されていること" do
        sign_in @user1
        stub_request(:post, "https://api.openai.com/v1/chat/completions").
          to_return(status: 200, body: { success: { message: "シフトが作成されました" } }.to_yaml)

        post shifts_path, params: { shift: { calendar: '2024-06-13', user_id: @user1.id }, password: 'password' }

        expect(response).to have_http_status(:success)
      end
    end

    context "特定の役職ごとのシフト作成" do
      it "リーダーが正しくシフトに含まれていること" do
        sign_in @user1
        ai_response = {
          choices: [
            {
              message: {
                content: "リーダー: yamada\nシフトタイプ: 固定シフト\n",
              },
            },
          ],
        }.to_json

        stub_request(:post, "https://api.openai.com/v1/chat/completions").
          to_return(status: 200, body: ai_response)

        post shifts_path, params: { shift: { calendar: '2024-06-13', user_id: @user1.id }, password: 'password' }
        expect(response).to have_http_status(:success)

        parsed_response = JSON.parse(ai_response)
        content = parsed_response["choices"][0]["message"]["content"]
        expect(content).to include("リーダー: yamada")
      end

      it "早番の社員が正しくシフトに含まれていること" do
        sign_in @user2
        ai_response = {
          choices: [
            {
              message: {
                content: "社員: tanaka\nシフトタイプ: 早番\n",
              },
            },
          ],
        }.to_json

        stub_request(:post, "https://api.openai.com/v1/chat/completions").
          to_return(status: 200, body: ai_response)

        post shifts_path, params: { shift: { calendar: '2024-06-13', user_id: @user2.id }, password: 'password' }
        expect(response).to have_http_status(:success)

        parsed_response = JSON.parse(ai_response)
        content = parsed_response["choices"][0]["message"]["content"]
        expect(content).to include("社員: tanaka")
      end

      it "遅番の社員が正しくシフトに含まれていること" do
        sign_in @user3
        ai_response = {
          choices: [
            {
              message: {
                content: "社員: sato\nシフトタイプ: 遅番\n",
              },
            },
          ],
        }.to_json

        stub_request(:post, "https://api.openai.com/v1/chat/completions").
          to_return(status: 200, body: ai_response)

        post shifts_path, params: { shift: { calendar: '2024-06-13', user_id: @user3.id }, password: 'password' }
        expect(response).to have_http_status(:success)

        parsed_response = JSON.parse(ai_response)
        content = parsed_response["choices"][0]["message"]["content"]
        expect(content).to include("社員: sato")
      end
    end

    context "パート・アルバイトのシフト作成" do
      it "パート・アルバイトのシフト時間が正しく反映されていること" do
        sign_in @user4
        ai_response = {
          choices: [
            {
              message: {
                content: "パート・アルバイト: matuda\nシフト: 10:00 ~ 15:00\n",
              },
            },
          ],
        }.to_json

        stub_request(:post, "https://api.openai.com/v1/chat/completions").
          to_return(status: 200, body: ai_response)

        post shifts_path, params: { shift: { calendar: '2024-06-13', user_id: @user4.id }, password: 'password' }
        expect(response).to have_http_status(:success)

        parsed_response = JSON.parse(ai_response)
        content = parsed_response["choices"][0]["message"]["content"]
        expect(content).to include("パート・アルバイト: matuda")
        expect(content).to include("10:00 ~ 15:00")
      end
    end

    context "役職ごとのシフトバランスの確認" do
      it "シフトにパート・アルバイト、社員、リーダーが含まれていること" do
        sign_in @user1
        ai_response = {
          choices: [
            {
              message: {
                content: "リーダー: yamada\n社員: sato\nパート・アルバイト: matuda\n",
              },
            },
          ],
        }.to_json

        stub_request(:post, "https://api.openai.com/v1/chat/completions").
          to_return(status: 200, body: ai_response)
        post shifts_path,
        params: { shift: { calendar: '2024-06-13', user_id: @user1.id }, password: 'password' }
        expect(response).to have_http_status(:success)
        parsed_response = JSON.parse(ai_response)
        content = parsed_response["choices"][0]["message"]["content"]
        expect(content).to include("リーダー")
        expect(content).to include("社員")
        expect(content).to include("パート・アルバイト")
      end
    end
  end
end
