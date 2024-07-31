require 'rails_helper'
require 'webdrivers'

RSpec.describe "Users", type: :system do
  let(:valid_user) { FactoryBot.build(:user) }
  let!(:registered_user) { FactoryBot.create(:user, email: 'registered@example.com', password: 'password') }

  it "新規ユーザーが正しく登録できること(社員 早番の場合)" do
    visit new_user_registration_path
    fill_in 'user_name', with: valid_user.name
    fill_in 'user_email', with: valid_user.email
    fill_in 'user_password', with: valid_user.password
    fill_in 'user_password_confirmation', with: valid_user.password_confirmation
    select '社員', from: 'user_classification'
    select '早番: 9時~18時', from: 'user_shift_type'
    click_button '新規登録'

    expect(page).to have_content 'アカウント登録が完了しました'
  end

  it "新規ユーザーが正しく登録できること(社員 遅番の場合)" do
    visit new_user_registration_path
    fill_in 'user_name', with: valid_user.name
    fill_in 'user_email', with: valid_user.email
    fill_in 'user_password', with: valid_user.password
    fill_in 'user_password_confirmation', with: valid_user.password_confirmation
    select '社員', from: 'user_classification'
    select '遅番: 13時~22時', from: 'user_shift_type'
    click_button '新規登録'

    expect(page).to have_content 'アカウント登録が完了しました'
  end

  it "新規ユーザーが正しく登録できること(パート・アルバイトの場合)" do
    visit new_user_registration_path
    fill_in 'user_name', with: valid_user.name
    fill_in 'user_email', with: valid_user.email
    fill_in 'user_password', with: valid_user.password
    fill_in 'user_password_confirmation', with: valid_user.password_confirmation
    select 'パート・アルバイト', from: 'user_classification'
    select '10', from: 'user_start_time_4i'
    select '00', from: 'user_start_time_5i'

    select '15', from: 'user_end_time_4i'
    select '00', from: 'user_end_time_5i'
    click_button '新規登録'

    expect(page).to have_content 'アカウント登録が完了しました'
  end

  it "新規ユーザーが正しく登録できること(リーダーの場合)" do
    visit new_user_registration_path
    fill_in 'user_name', with: valid_user.name
    fill_in 'user_email', with: valid_user.email
    fill_in 'user_password', with: valid_user.password
    fill_in 'user_password_confirmation', with: valid_user.password_confirmation
    select 'リーダー', from: 'user_classification'
    select '固定シフト', from: 'user_shift_type'
    click_button '新規登録'

    expect(page).to have_content 'アカウント登録が完了しました'
  end

  it "誤った情報でログインするとエラーメッセージが表示されること" do
    visit new_user_session_path
    fill_in 'メールアドレス', with: 'wrong@example.com'
    fill_in 'パスワード', with: 'wrongpassword'
    click_button 'ログイン'
    expect(page).to have_content 'メールアドレスまたはパスワードが違います'
  end

  it "ログイン後にログアウトできること" do
    visit new_user_session_path
    fill_in 'メールアドレス', with: 'registered@example.com'
    fill_in 'パスワード', with: 'password'
    click_button 'ログイン'

    click_link 'ログアウト'
    page.driver.browser.switch_to.alert.accept
    expect(page).to have_content 'ログアウトしました'
  end

  it "ユーザーがアカウント詳細を見れる" do
    visit new_user_session_path
    fill_in 'user_email', with: 'registered@example.com'
    fill_in 'user_password', with: 'password'
    click_button 'ログイン'

    expect(page).to have_content 'ログインしました'

    visit users_account_path

    expect(page).to have_content(registered_user.name)
    expect(page).to have_content(registered_user.email)
    expect(page).to have_content(registered_user.classification)
    expect(page).to have_content(registered_user.shift_type)
  end

  it "ユーザーがアカウント情報を変更できる" do
    visit new_user_session_path
    fill_in 'user_email', with: 'registered@example.com'
    fill_in 'user_password', with: 'password'
    click_button 'ログイン'

    expect(page).to have_content 'ログインしました'

    visit edit_user_registration_path

    fill_in 'user_email', with: 'updated@example.com'
    fill_in 'user_current_password', with: 'password'
    click_button '更新'

    registered_user.reload
    expect(registered_user.reload.email).to eq('updated@example.com')
  end
end
