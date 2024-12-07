require 'rails_helper'

RSpec.describe "Favorites", type: :system do
  let!(:shift) { FactoryBot.create(:shift) }
  let(:user) { FactoryBot.create(:user) }

  before do
    sign_in user
    visit shifts_path
  end

  it "おに入り登録した後に解除できること" do
    click_on 'お気に入り登録', match: :first
    expect(page).to have_content('お気に入り登録しました')
    click_on 'お気に入り解除', match: :first
    expect(page).to have_content('お気に入り登録を解除しました')
  end

  it "おに入り登録したしたシフトがお気にりページに反映されていること" do
    click_on 'お気に入り登録', match: :first
    expect(page).to have_content('お気に入り登録しました')
    visit favorite_user_path(user)
    expect(page).to have_content(shift.calendar.to_s)
    expect(page).to have_content(shift.content)
    expect(page).to have_content(shift.creator)
  end
end
