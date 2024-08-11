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
require "test_helper"

class ShiftTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
