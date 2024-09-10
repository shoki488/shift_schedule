# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  classification         :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  end_time               :integer
#  name                   :string
#  overtime               :integer
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  shift_type             :string
#  start_time             :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  has_many :shift_users
  has_many :shifts, through: :shift_users

  def create_shift_with_openai
    OpenAi.create_shift(self)
  end
  
  def self.guest
    find_or_create_by!(email: 'guest@example.com') do |user|
      user.password = SecureRandom.urlsafe_base64
      user.password_confirmation = user.password 
      user.name = 'ゲスト'
      user.classification = 'ゲスト' 
    end
  end

  def guest?
    email == 'guest@example.com'
  end

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :password, confirmation: true
  validates :password_confirmation, presence: true, if: :password_required?
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :classification, presence: true
  validate :start_time_and_end_time_within_business_hours, if: -> { classification == 'パート・アルバイト' }
  validate :end_time_after_start_time, if: -> { classification == 'パート・アルバイト' }
  validate :end_time_same_start_time, if: -> { classification == 'パート・アルバイト' }
  validate :shift_duration_within_limit, if: -> { classification == 'パート・アルバイト' }

  
  def start_time_and_end_time_within_business_hours
    business_start = Time.zone.parse("09:00")
    business_end = Time.zone.parse("22:00")
    
    if start_time.present? && (start_time.seconds_since_midnight < business_start.seconds_since_midnight || start_time.seconds_since_midnight > business_end.seconds_since_midnight)
      errors.add(:start_time, "は営業時間内（9:00から22:00）にしてください。")
    end

    if end_time.present? && (end_time.seconds_since_midnight < business_start.seconds_since_midnight || end_time.seconds_since_midnight > business_end.seconds_since_midnight)
      errors.add(:end_time, "は営業時間内（9:00から22:00）にしてください。")
    end
  end

  def end_time_after_start_time
    if start_time.present? && end_time.present? && end_time < start_time
      errors.add(:end_time, "は開始時間より後にしてください。")
    end
  end

  def end_time_same_start_time
    if start_time.present? && end_time.present? && end_time == start_time
      errors.add(:end_time, "開始時間と終了時間が同じになっています。")
    end
  end

  def shift_duration_within_limit
    if start_time.present? && end_time.present?
      duration = (end_time - start_time) / 1.hour
      if duration > 8
        errors.add(:base, "勤務時間は8時間以内にしてください。")
      end
    end
  end
  
  private

  def password_required?
    new_record? || password.present? || password_confirmation.present?
  end
end
