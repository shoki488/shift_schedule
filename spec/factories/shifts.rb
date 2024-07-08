# == Schema Information
#
# Table name: shifts
#
#  id         :integer          not null, primary key
#  calendar   :date
#  content    :text
#  creator    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#
FactoryBot.define do
  factory :shift do
    calendar { "2025-07-07" }
    creator { "yokota" }
    content { "これはAIの返答を模倣しているデータです。" }
  end
end
