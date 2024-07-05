# == Schema Information
#
# Table name: shift_users
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  shift_id   :integer
#  user_id    :integer
#
require 'rails_helper'

RSpec.describe ShiftUser, type: :model do
  describe 'アソシエーションのテスト' do
    it 'shift_usersjはuserと1対1の関係持つこと' do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq :belongs_to
    end

    it 'shift_usersはShiftと1対1の関係持つこと' do
      association = described_class.reflect_on_association(:shift)
      expect(association.macro).to eq :belongs_to
    end
  end
end
