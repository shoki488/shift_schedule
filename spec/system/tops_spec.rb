require 'rails_helper'
require 'webdrivers'

RSpec.describe "Tops", type: :system do
  it "トップページの画像が表示されること" do
    visit root_path
    expect(page).to have_css('.main img[src*="job.jpg"]')
  end

  it "Shfit Scheduleをクリックしてホームに接続できること" do
    visit root_path
    click_link 'Shift Schedule'
    expect(page).to have_current_path(root_path)
  end

  context "ログイン、新規登録した時のトップページ" do
    let(:user) { FactoryBot.create(:user) }

    before do
      visit root_path
      login_as(user, scope: :user)
      visit root_path
    end

    it "ログイン、新規登録をした際の名前が表示されてること" do
      expect(page).to have_content(user.name)
    end

    it "メニュー欄のホームをクリックしてホームに接続できること" do
      find('.dropdown-toggle').click
      click_link 'ホーム'
      expect(page).to have_current_path(root_path)
    end

    it "メニュー欄のシフト一覧をクリックしてシフト一覧ページに接続できること" do
      find('.dropdown-toggle').click
      click_link 'シフト一覧'
      expect(page).to have_current_path(shifts_path)
    end

    it "メニュー欄のシフト作成をクリックしてシフト作成ページに接続できること" do
      find('.dropdown-toggle').click
      click_link('シフト作成')
      expect(page).to have_current_path(new_shift_path)
    end

    it "メニュー欄のアカウント詳細をクリックしてアカウント詳細ページに接続できること" do
      find('.dropdown-toggle').click
      click_link 'アカウント詳細'
      expect(page).to have_current_path(users_account_path)
    end

    it "メニュー欄のアカウント変更をクリックしてアカウント変更ページに接続できること" do
      find('.dropdown-toggle').click
      click_link 'アカウント変更'
      expect(page).to have_current_path(edit_user_registration_path)
    end

    it "トップページにシフト作成ボタン、ログアウトボタンが表示されていること" do
      expect(page).to have_link('シフト作成', href: new_shift_path)
      expect(page).to have_link('ログアウト', href: destroy_user_session_path)
    end

    it "シフト作成ボタンからシフト作成ページの接続できること" do
      click_link 'シフト作成はこちら'
      expect(page).to have_current_path(new_shift_path)
    end

    it "ログアウトボタンからログアウトできること" do
      click_link 'ログアウト'
      page.driver.browser.switch_to.alert.accept
      expect(page).to have_content 'ログアウトしました'
    end
  end

  context "ログアウト時のログアウト時のトップページ" do
    before do
      visit root_path
    end

    it "ヘッダー欄に？が表示されていること" do
      expect(page).to have_content("？")
    end

    it "ヘッダー欄の？をクリックすると使い方ページに接続できること" do
      click_link "？"
      expect(page).to have_current_path(question_path)
    end

    it "トップページにログイン、新規登録、ゲストログインが表示されていること" do
      expect(page).to have_link('ログイン', href: new_user_session_path)
      expect(page).to have_link('新規登録', href: new_user_registration_path)
      expect(page).to have_link('ゲストログイン', href: users_guest_sign_in_path)
    end

    it "ログインボタンからログイン画面に接続できること" do
      click_link 'ログイン'
      expect(page).to have_current_path(new_user_session_path)
    end

    it "新規登録ボタンから新規登録画面に接続できること" do
      click_link '新規登録'
      expect(page).to have_current_path(new_user_registration_path)
    end

    it "ゲストログインボタンからゲストログインできヘッダーにゲストが表示されていること" do
      click_link 'ゲストログイン'
      expect(page).to have_current_path(root_path)
      expect(page).to have_content("ゲスト")
    end
  end
end
