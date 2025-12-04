require 'rails_helper'

RSpec.describe "Header navigation", type: :system do
  let!(:user) { User.create!(name: "翔", email: "test@example.com", password: "password") }

  before do
    driven_by(:rack_test)
  end

  context "when not logged in" do
    it "shows PCPACK logo linking to login" do
      visit root_path
      within("nav.navbar") do
        expect(page).to have_link("PCPACK", href: new_user_session_path)
      end
    end

    it "does not show menu dropdown" do
      visit root_path
      expect(page).not_to have_selector("#menuDropdown")
    end
  end

  context "when logged in" do
    before do
      login_as(user, scope: :user)
    end

    it "shows user avatar and DM link" do
      visit root_path
      within("nav.navbar") do
        expect(page).to have_selector("img.user-avatar")
        expect(page).to have_link(nil, href: user_dmpage_path(user))
      end
    end

    it "shows PCPACK logo linking to root" do
      visit root_path
      within("nav.navbar") do
        expect(page).to have_link("PCPACK", href: root_path)
      end
    end

    it "shows menu dropdown with links" do
      visit root_path
      find("#menuDropdown").click
      expect(page).to have_link("投稿", href: new_post_path)
      expect(page).to have_link("投稿一覧", href: posts_path)
      expect(page).to have_link("マイページ", href: mypage_path)
      expect(page).to have_link("ブックマーク", href: bookmarks_path)
      expect(page).to have_button("ログアウト")
    end
  end
end