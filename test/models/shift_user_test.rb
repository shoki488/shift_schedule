# == Schema Information
#
# Table name: shift_users
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  shift_id   :integer
#  user_id    :integer
#
require "test_helper"

class ShiftUserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
