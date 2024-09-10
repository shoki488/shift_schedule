# == Schema Information
#
# Table name: shifts
#
#  id                :bigint           not null, primary key
#  calendar          :date
#  content           :text
#  creator           :string
#  overtime_eligible :boolean          default(FALSE), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  user_id           :integer
#
class Shift < ApplicationRecord
  has_many :shift_users
  has_many :users, through: :shift_users

  validates :calendar, presence: true
  validate :today_after_calendar
  validates :creator, presence: true

  def today_after_calendar
    if calendar.present? && calendar < Date.today
      errors.add(:calendar, "本日以降の日付を選んでください。")
    end
  end
end
