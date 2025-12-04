require 'rails_helper'

RSpec.describe "User DM page", type: :system do
  let!(:sender)    { User.create!(name: "送信者", email: "sender@example.com", password: "password") }
  let!(:recipient) { User.create!(name: "受信者", email: "recipient@example.com", password: "password") }
  let!(:room)      { Room.create!(uuid: SecureRandom.uuid) }

  # Room に参加者を紐付ける（partner と uuid を必ず指定）
  let!(:sender_entry) do
    Entry.create!(room: room, user: sender, partner: recipient, uuid: SecureRandom.uuid)
  end
  let!(:recipient_entry) do
    Entry.create!(room: room, user: recipient, partner: sender, uuid: SecureRandom.uuid)
  end

  # Message に recipient を必ず指定
  let!(:message) do
    Message.create!(
      user: sender,
      recipient: recipient,   # ← これが必須
      subject: "テスト件名",
      body: "テスト本文",
      room: room,
      uuid: SecureRandom.uuid
    )
  end

  before do
    driven_by(:rack_test)
    login_as(recipient, scope: :user)
  end

  it "shows DM page title" do
    visit user_dmpage_path(recipient)
    expect(page).to have_content("#{recipient.name}さんのメールBOX")
  end

  it "lists received messages" do
    visit user_dmpage_path(recipient)
    expect(page).to have_content("受信一覧")
    expect(page).to have_content("テスト件名")
    expect(page).to have_content("送信者：送信者")
  end

  it "shows message details when clicked" do
    visit user_dmpage_path(recipient, message_id: message.uuid)
    expect(page).to have_content("送信者：送信者")
    expect(page).to have_content("件名：テスト件名")
    expect(page).to have_content("テスト本文")
  end


  it "allows replying to a message", js: true do
    visit user_dmpage_path(recipient, message_id: message.uuid)

    fill_in "返信コメント", with: "返信テスト"
    click_button "返信"

    expect(page).to have_content("返信テスト")
  end

  it "has link to new message creation" do
    visit user_dmpage_path(recipient)
    expect(page).to have_link("新規メール作成", href: newdmpage_user_path(recipient))
  end
end