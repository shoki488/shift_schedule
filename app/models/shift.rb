# == Schema Information
#
# Table name: shifts
#
#  id                :bigint           not null, primary key
#  calendar          :date
#  content           :text
#  creator           :string
#  overtime_eligible :boolean          default(FALSE), not null
#  shift_type        :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  user_id           :integer
#
class Shift < ApplicationRecord
  has_many :shift_users
  has_many :assigned_users, through: :shift_users, source: :user
  has_many :favorited_by_users, through: :favorites, source: :user
  has_many :favorites, dependent: :destroy

  validates :calendar, presence: true
  validate :today_after_calendar
  validates :creator, presence: true

  def self.looks(search, word)
    return all if word.blank?

    case search
    when "perfect_match"
      where("calendar::text LIKE ? OR creator LIKE ?", word, word)
    when "forward_match"
      where("calendar::text LIKE ? OR creator LIKE ?", "#{word}%", "#{word}%")
    when "backward_match"
      where("calendar::text LIKE ? OR creator LIKE ?", "%#{word}", "%#{word}")
    when "partial_match"
      where("calendar::text LIKE ? OR creator LIKE ?", "%#{word}%", "%#{word}%")
    else
      all
    end
  end

  def today_after_calendar
    if calendar.present? && calendar < Date.today
      errors.add(:calendar, "本日以降の日付を選んでください。")
    end
  end
end
