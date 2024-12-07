# == Schema Information
#
# Table name: shift_preferences
#
#  id              :bigint           not null, primary key
#  date            :date
#  end_time        :time
#  name            :string
#  notes           :text
#  preference_type :string
#  shift_type      :string
#  start_time      :time
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_shift_preferences_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe ShiftPreference, type: :model do
  let(:user) { FactoryBot.build(:user) }
  let(:shift_preference) { FactoryBot.build(:shift_preference, user: user) }
  it 'Userと1対1の関係を持つこと' do
    association = described_class.reflect_on_association(:user)
    expect(association.macro).to eq :belongs_to
  end

  context 'パート・アルバイトの場合' do
    before do
      user.update(classification: 'パート・アルバイト')
    end
    it 'パート・アルバイトで時間が８時間を超えた場合バリデーションが出ること' do
      shift_preference.start_time = '9:00'
      shift_preference.end_time = '20:00'
      shift_preference.valid?
      expect include("保存に失敗しました。登録内容を確認し直してください。")
    end

    it 'パート・アルバイトで時間が同じ場合バリデーションが出ること' do
      shift_preference.start_time = '9:00'
      shift_preference.end_time = '9:00'
      shift_preference.valid?
      expect include("保存に失敗しました。登録内容を確認し直してください。")
    end

    it 'パート・アルバイトで開始時間が終了時間よりも後の場合バリデーションが出ること' do
      shift_preference.start_time = '12:00'
      shift_preference.end_time = '9:00'
      shift_preference.valid?
      expect include("保存に失敗しました。登録内容を確認し直してください。")
    end
  end
end
