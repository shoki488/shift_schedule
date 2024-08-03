require 'rails_helper'

RSpec.describe "Shifts", type: :system do
  let!(:shifts) { FactoryBot.create_list(:shift, 3) }
  let(:shift) { FactoryBot.create(:shift) }
  let(:user) { FactoryBot.create(:user) }

  before do
    sign_in user
  end

  it "日付、シフト作成者、パスワードを入力した後シフト作成し詳細画面に移動できる" do
    visit new_shift_path
    fill_in 'shift_calendar', with: '2025/07/07'
    select user.name, from: 'shift_user_id'
    fill_in 'password', with: ENV['SHIFT_CREATION_PASSWORD']
    click_button 'シフト作成'
    visit shifts_path
    expect(page).to have_content('2025-07-07')
  end

  it "シフト削除ができること" do
    visit shifts_path
    click_on 'シフト削除', match: :first
    expect(page).to have_content('シフトを削除しました')
  end

  it "シフト一覧画面にこれまでのシフト作成日,シフト作成者が表示されること" do
    visit shifts_path
    shifts.each do |shift|
      expect(page).to have_content(shift.calendar)
      expect(page).to have_content(shift.content)
      expect(page).to have_content(shift.creator)
    end
  end
end
