require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:guest_user) { User.find_or_create_by(email: 'guest@example.com')do |user|
  user.name = 'ゲスト'
  user.classification = 'ゲスト'
  user.password = 'password'
  end }
  describe 'ログインした時' do
    before do
      sign_in user
    end

    context 'GET #index' do
      it 'ログインした時、ユーザーの名前を含んでトップページが表示できること' do
        get root_path
        expect(response.status).to eq 200
        expect(response.body).to include(user.name)
      end
    end

    context 'GET /users/account' do
      it 'アカウント詳細ページが表示されること' do
        get users_account_path
        expect(response.status).to eq(200)
      end

      it 'アカウント詳細ページで名前、メールアドレス、役職、シフトタイプが表示されていること' do
        get users_account_path
        expect(response.body).to include(user.name)
        expect(response.body).to include(user.email)
        expect(response.body).to include(user.classification)
        expect(response.body).to include(user.shift_type)
      end
    end

    context 'GET #edit' do
      it 'アカウント変更ページが表示されること' do
        get edit_user_registration_path
        expect(response.status).to eq(200)
      end

      it 'アカウント情報が正常に更新されること' do
        get edit_user_registration_path
        valid_attributes = {
          user: {
            name: 'Updated Name',
            email: 'updated_email@example.com',
            current_password: user.password,
          },
        }

        patch user_registration_path, params: valid_attributes

        expect(response).to redirect_to(users_account_path(user))
        follow_redirect!
        user.reload
        expect(user.name).to eq('Updated Name')
        expect(user.email).to eq('updated_email@example.com')
      end

      it '無効なデータでユーザー情報が更新されないこと' do
        get edit_user_registration_path
        invalid_attributes = {
          user: {
            name: '',
            email: 'invalid_email',
            current_password: user.password,
          },
        }

        patch user_registration_path, params: invalid_attributes
        expect(response).to have_http_status(:unprocessable_entity)
        user.reload
        expect(user.name).not_to eq('')
      end
    end

    context 'DELETE /users/sign_out' do
      it 'ユーザーがログアウトできること' do
        delete destroy_user_session_path
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include("ログアウトしました")
      end
    end
  end

  describe 'ゲストユーザーのアクセス制限' do
    before do
      sign_in guest_user
    end

    context 'ゲストユーザーの情報にアクセス' do
      it 'ゲストユーザーの詳細ページにアクセスできないこと' do
        get users_account_path
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include("ゲストユーザーのアカウント情報は閲覧・変更できません。")
      end

      it 'ゲストユーザーの編集ページにアクセスできないこと' do
        get edit_user_registration_path
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include("ゲストユーザーのアカウント情報は閲覧・変更できません。")
      end
    end
  end
end
