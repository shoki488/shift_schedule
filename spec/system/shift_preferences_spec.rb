require 'rails_helper'

RSpec.describe "Shift_References", type: :system do
  let(:shift_preference) { FactoryBot.build(:shift_preference, user: user) }
  let(:user) { FactoryBot.create(:user, classification: '社員', shift_type: '遅番') }
  let(:part) { FactoryBot.create(:user, classification: 'パート・アルバイト') }

  it "シフト希望日を登録できること" do
    sign_in user
    visit new_shift_preference_path

    within all('.calendar-day')[4] do
      find('.preferred-date-checkbox', visible: false).click
    end
    click_button 'まとめて保存'
    expect(shift_preference.preference_type).to eq '⭕️'
  end

  it "社員がシフト希望でメモとシフトタイプ登録がきること" do
    sign_in user
    visit new_shift_preference_path

    first('.calendar-day').find('.shift-type').select('早番')
    first('.calendar-day').find('.note-input').fill_in with: 'MyText'
    click_button 'まとめて保存'
    expect(shift_preference.shift_type).to eq '早番'
    expect(shift_preference.notes).to eq 'MyText'
  end

  it "パート・アルバイトがシフト希望で時間帯とメモを登録できること" do
    sign_in part
    visit new_shift_preference_path

    first('.calendar-day').find('.start-time').select('10:00')
    first('.calendar-day').find('.end-time').select('15:00')
    first('.calendar-day').find('.note-input').fill_in with: 'MyText'
    click_button 'まとめて保存'
    expect(shift_preference.start_time.strftime("%H:%M")).to eq '10:00'
    expect(shift_preference.end_time.strftime("%H:%M")).to eq '15:00'
    expect(shift_preference.notes).to eq 'MyText'
  end
end
