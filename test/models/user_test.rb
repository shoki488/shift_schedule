# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  classification         :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  end_time               :time
#  name                   :string
#  overtime               :integer
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  shift_type             :string
#  start_time             :time
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
require "test_helper"

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
