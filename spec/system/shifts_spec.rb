require 'rails_helper'

RSpec.describe "Shifts", type: :system do
  let!(:shifts) { FactoryBot.create_list(:shift, 3) }
  let(:user) { FactoryBot.create(:user) }
  let(:leader) { FactoryBot.create(:user, :leader) }

  before do
    sign_in user
    visit shifts_path
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

  it "社員とリーダーのみシフト削除ができること" do
    sign_in leader
    visit shifts_path
    click_on 'シフト削除', match: :first
    expect(page).to have_content('シフトを削除しました')
  end

  it "シフト一覧画面にこれまでのシフト作成日,シフト作成者が表示されること" do
    shifts.each do |shift|
      expect(page).to have_content(shift.calendar)
      expect(page).to have_content(shift.content)
      expect(page).to have_content(shift.creator)
    end
  end

  describe "並び替え機能", js: true do
    before do
      visit shifts_path
      find('#sort').click
    end

    it "昇順に並び替えができること" do
      select '日付（昇順）', from: 'sort'
      expect(page).to have_current_path(shifts_path(sort: "date_asc"))
    end

    it "降順に並び替えができること" do
      select '日付（降順）', from: 'sort'
      expect(page).to have_current_path(shifts_path(sort: "date_desc"))
    end

    it "作成順に並び替えができること" do
      select '作成順', from: 'sort'
      expect(page).to have_current_path(shifts_path)
    end

    it "ソートオプションが正しく表示されていること" do
      expect(page).to have_select('sort', options: ['作成順', '日付（昇順）', '日付（降順）'])
    end

    it "デフォルトで作成順が選択されていること" do
      expect(page).to have_select('sort', selected: '作成順')
    end
  end
end
