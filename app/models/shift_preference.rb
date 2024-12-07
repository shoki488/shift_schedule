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
class ShiftPreference < ApplicationRecord
  belongs_to :user

  def classification
    user.classification
  end

  validate :start_time_and_end_time_within_business_hours, if: -> { user&.classification == 'パート・アルバイト' }
  validate :end_time_after_start_time, if: -> { user&.classification == 'パート・アルバイト' }
  validate :end_time_same_start_time, if: -> { user&.classification == 'パート・アルバイト' }
  validate :shift_duration_within_limit, if: -> { user&.classification == 'パート・アルバイト' }

  def start_time_and_end_time_within_business_hours
    business_start = Time.zone.parse("9:00") # rubocop:disable Lint/UselessAssignment
    business_end = Time.zone.parse("22:00") # rubocop:disable Lint/UselessAssignment
  end

  def end_time_after_start_time
    if start_time.present? && end_time.present? && end_time < start_time
      errors.add(:end_time, "は開始時間より後に設定してください")
    end
  end

  def end_time_same_start_time
    if start_time.present? && end_time.present? && end_time == start_time
      errors.add(:end_time, "は開始時間と同じになっています")
    end
  end

  def shift_duration_within_limit
    if start_time.present? && end_time.present?
      duration = (end_time - start_time) / 3600.0
      if duration > 8
        errors.add(:base, "シフトの長さは最大8時間までです")
      end
    end
  end
end
