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
class ShiftUser < ApplicationRecord
  belongs_to :user
  belongs_to :shift
end
