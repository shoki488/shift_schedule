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
FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "User #{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password" }
    password_confirmation { "password" }
    classification { '社員' }
    shift_type { '早番' }

    trait :leader do
      classification { 'リーダー' }
    end

    trait :part_time do
      classification { 'パート・アルバイト' }
      start_time { '10:00' }
      end_time { '15:00' }
    end

    trait :night_shift do
      shift_type { '遅番' }
    end

    factory :user_shift do
      user
      shift
    end
  end
end
