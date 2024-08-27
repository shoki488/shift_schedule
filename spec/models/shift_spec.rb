# == Schema Information
#
# Table name: shifts
#
#  id                :integer          not null, primary key
#  calendar          :date
#  content           :text
#  creator           :string
#  overtime_eligible :boolean          default(FALSE), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  user_id           :integer
#
require 'rails_helper'

RSpec.describe Shift, type: :model do
  let(:shift) { FactoryBot.build(:shift) }

  describe 'アソシエーション' do
    it 'shfitはUserShiftを複数持つこと' do
      association = described_class.reflect_on_association(:shift_users)
      expect(association.macro).to eq :has_many
    end

    it 'shiftはshift_usersを介してShiftを複数持つこと' do
      association = described_class.reflect_on_association(:users)
      expect(association.macro).to eq :has_many
      expect(association.options[:through]).to eq :shift_users
    end
  end

  describe 'バリデーション' do
    it 'シフト作成日が指定されていない場合、無効であること' do
      shift.calendar = nil
      expect(shift).not_to be_valid
      expect(shift.errors[:calendar]).to include("を入力してください")
    end

    it 'シフト作成日の指定が本日より前の日付なら、無効であること' do
      shift.calendar = Date.new(2023, 8, 8)
      expect(shift).not_to be_valid
      expect(shift.errors[:calendar]).to include("本日以降の日付を選んでください。")
    end

    it '明日以降の日付なら、有効であること' do
      shift.calendar = Date.tomorrow
      expect(shift).to be_valid
    end
    
    it '本日の日付なら、有効であること' do
      shift.calendar = Date.today
      expect(shift).to be_valid
    end

    it 'シフト作成者が指定されていない場合、無効であること' do
      shift.creator = nil
      expect(shift).not_to be_valid
      expect(shift.errors[:creator]).to include("を入力してください")
    end
  end
end
