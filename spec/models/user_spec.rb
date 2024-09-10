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
require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { FactoryBot.build(:user) }

  describe 'アソシエーションのテスト' do
    it 'UserはUserShiftを複数持つこと' do
      association = described_class.reflect_on_association(:shift_users)
      expect(association.macro).to eq :has_many
    end

    it 'Userはshift_usersを介してShiftを複数持つこと' do
      association = described_class.reflect_on_association(:shifts)
      expect(association.macro).to eq :has_many
      expect(association.options[:through]).to eq :shift_users
    end
  end

  describe 'バリデーションテスト' do
    it '名前がない場合、無効であること' do
      user.name = nil
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("を入力してください")
    end

    it 'メールアドレスがない場合、無効であること' do
      user.email = nil
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("を入力してください")
    end

    it 'メールアドレスが一意でない場合、無効であること' do
      FactoryBot.create(:user, email: user.email)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("はすでに存在します")
    end

    it 'パスワードがない場合、無効であること' do
      user.password = nil
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("を入力してください")
    end

    it '確認用パスワードがない場合、無効であること' do
      user.password_confirmation = nil
      expect(user).not_to be_valid
      expect(user.errors[:password_confirmation]).to include("を入力してください")
    end

    it 'パスワードとパスワード確認が一致している場合、有効であること' do
      user.password = 'password'
      user.password_confirmation = 'password'
      expect(user).to be_valid
    end

    it 'パスワードとパスワード確認が一致しない場合、無効であること' do
      user.password = 'password'
      user.password_confirmation = 'password1'
      expect(user).not_to be_valid
      expect(user.errors[:password_confirmation]).to include("とパスワードの入力が一致しません")
    end

    it '役職がない場合、無効であること' do
      user.classification = nil
      expect(user).not_to be_valid
      expect(user.errors[:classification]).to include("を入力してください")
    end

    it '社員だった場合、早番を選択していること' do
      user.classification = '社員'
      user.shift_type = '早番'
      expect(user).to be_valid
    end

    it '社員だった場合、遅番を選択していること' do
      user.classification = '社員'
      user.shift_type = '遅番'
      expect(user).to be_valid
    end

    it 'パート・アルバイトだった場合、時間を選択していること' do
      user.classification = 'パート・アルバイト'
      user.start_time = '10:00'
      user.end_time = '15:00'
      expect(user).to be_valid
    end

    it 'パート・アルバイトで営業時間外だった場合バリデーションが出ること' do
      user.classification = 'パート・アルバイト'
      user.start_time = '8:00'
      user.end_time = '15:00'
      user.valid?
      expect(user.errors[:start_time]).to include("は営業時間内（9:00から22:00）にしてください。")
    end

    it 'パート・アルバイトで時間が８時間を超えた場合バリデーションが出ること' do
      user.classification = 'パート・アルバイト'
      user.start_time = '9:00'
      user.end_time = '20:00'
      user.valid?
      expect(user.errors[:base]).to include("勤務時間は8時間以内にしてください。")
    end

    it 'パート・アルバイトで時間が同じ場合バリデーションが出ること' do
      user.classification = 'パート・アルバイト'
      user.start_time = '9:00'
      user.end_time = '9:00'
      user.valid?
      expect(user.errors[:end_time]).to include("開始時間と終了時間が同じになっています。")
    end

    it 'パート・アルバイトで開始時間が終了時間よりも後の場合バリデーションが出ること' do
      user.classification = 'パート・アルバイト'
      user.start_time = '12:00'
      user.end_time = '9:00'
      user.valid?
      expect(user.errors[:end_time]).to include("は開始時間より後にしてください。")
    end

    it 'ゲストユーザーが作成されること' do
      guest_user = User.guest
      expect(guest_user.email).to eq 'guest@example.com'
      expect(guest_user.name).to eq 'ゲスト'
    end

    it 'ゲストユーザーである場合trueを返すこと' do
      guest_user = User.guest
      expect(guest_user.guest?).to be true
    end

    it 'ゲストユーザーでない場合falseを返すこと' do
      regular_user = FactoryBot.create(:user)
      expect(regular_user.guest?).to be false
    end
  end
end
