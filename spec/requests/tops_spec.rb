require 'rails_helper'

RSpec.describe "TopPages", type: :request do
  let(:user) { FactoryBot.create(:user) }

  describe 'トップページ' do
    it 'ステータス200 OKであること' do
      get root_path
      expect(response).to have_http_status(200)
    end

    context 'ログインしていない場合' do
      it '「ログイン」リンクが表示されること' do
        get root_path
        expect(response.body).to include("ログイン")
      end

      it '「新規登録」リンクが表示されること' do
        get root_path
        expect(response.body).to include("新規登録")
      end
    end

    context 'ログイン、新規登録している場合' do
      before do
        sign_in user
      end

      it 'ヘッダーのホームが表示さえれ繋がること' do
        get root_path
        expect(response.body).to include("ホーム")
      end

      it 'ヘッダーのシフト作成が表示さえれ繋がること' do
        get new_shift_path
        expect(response.body).to include("シフト作成")
      end

      it 'ヘッダーのシフト一覧が表示さえれ繋がること' do
        get shifts_path
        expect(response.body).to include("シフト一覧")
      end

      it 'ヘッダーのアカウント詳細が表示さえれ繋がること' do
        get users_account_path
        expect(response.body).to include("アカウント詳細")
      end

      it 'ヘッダーのアカウント変更が表示さえれ繋がること' do
        get edit_user_registration_path
        expect(response.body).to include("アカウント変更")
      end

      it '新規登録リンクが表示されること' do
        get root_path
        expect(response.body).to include("ログアウト")
      end

      it 'ログアウトリンクが表示されること' do
        get root_path
        expect(response.body).to include("ログアウト")
      end
    end
  end
end
