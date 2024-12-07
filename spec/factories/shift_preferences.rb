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
FactoryBot.define do
  factory :shift_preference do
    user { "yazawa" }
    date { "2024-10-29" }
    start_time { '10:00' }
    end_time { '15:00' }
    preference_type { "⭕️" }
    notes { "MyText" }
    shift_type { "早番" }
  end
end
