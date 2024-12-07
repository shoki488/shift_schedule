# == Schema Information
#
# Table name: favorites
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  shift_id   :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_favorites_on_shift_id  (shift_id)
#  index_favorites_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (shift_id => shifts.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Favorite, type: :model do
  let(:shift) { FactoryBot.build(:shift) }

  it 'faovoriteはをuserと1対1の関係を持つこと' do
    association = described_class.reflect_on_association(:user)
    expect(association.macro).to eq :belongs_to
  end

  it 'favoriteはShiftと1対1の関係持つこと' do
    association = described_class.reflect_on_association(:shift)
    expect(association.macro).to eq :belongs_to
  end
end
