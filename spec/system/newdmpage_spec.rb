require 'rails_helper'

RSpec.describe "New DM page", type: :system do
  let!(:sender) { User.create!(name: "送信者", email: "sender@example.com", password: "password") }
  let!(:recipient) { User.create!(name: "受信者", email: "recipient@example.com", password: "password") }
  let!(:room) { Room.create! }

  before do
    driven_by(:rack_test)
    login_as(sender, scope: :user)
  end

  it "shows new message form" do
    visit newdmpage_user_path(sender)
    expect(page).to have_content("新規メール作成")
    expect(page).to have_field("宛先")
    expect(page).to have_field("件名")
    expect(page).to have_field("メッセージ内容")
    expect(page).to have_button("送信")
  end

  it "creates a new message successfully" do
    visit newdmpage_user_path(sender)
    select recipient.name, from: "宛先"
    fill_in "件名", with: "テスト件名"
    fill_in "メッセージ内容", with: "テスト本文"
    click_button "送信"

    # 成功時はメールBOX画面に遷移するのでそれを確認
    expect(page).to have_content("#{sender.name}さんのメールBOX")
    expect(Message.last.subject).to eq("テスト件名")
    expect(Message.last.body).to eq("テスト本文")
    expect(Message.last.recipient).to eq(recipient)
  end

  it "shows error when body is blank" do
    visit newdmpage_user_path(sender)
    select recipient.name, from: "宛先"
    fill_in "件名", with: "テスト件名"
    fill_in "メッセージ内容", with: ""
    click_button "送信"

    # 実際の挙動に合わせる
    expect(page).to have_content("本文を入力してください")
  end

  it "shows error when recipient is not selected" do
    visit newdmpage_user_path(sender)
    fill_in "件名", with: "テスト件名"
    fill_in "メッセージ内容", with: "本文あり"
    click_button "送信"

    expect(page).to have_content("宛先を選択してください")
  end
end