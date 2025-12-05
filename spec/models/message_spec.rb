require 'rails_helper'

RSpec.describe Message, type: :model do
  let!(:sender) { User.create!(name: "送信者", email: "sender@example.com", password: "password") }
  let!(:recipient) { User.create!(name: "受信者", email: "recipient@example.com", password: "password") }
  let!(:room) { Room.create!(uuid: SecureRandom.uuid) }

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:recipient).class_name("User") }
    it { is_expected.to belong_to(:room) }
    it { is_expected.to have_many(:replies).dependent(:destroy) }
  end

  describe "validations" do
    it "is valid with subject and body" do
      message = Message.new(user: sender, recipient: recipient, room: room, subject: "件名", body: "本文")
      expect(message).to be_valid
    end

    it "is invalid without body" do
      message = Message.new(user: sender, recipient: recipient, room: room, subject: "件名", body: nil)
      expect(message).not_to be_valid
      expect(message.errors[:body]).to be_present
    end

    it "is invalid with too long subject" do
      message = Message.new(user: sender, recipient: recipient, room: room, subject: "a" * 101, body: "本文")
      expect(message).not_to be_valid
      expect(message.errors[:subject]).to be_present
    end

    it "is invalid with too long body" do
      message = Message.new(user: sender, recipient: recipient, room: room, subject: "件名", body: "a" * 1001)
      expect(message).not_to be_valid
      expect(message.errors[:body]).to be_present
    end

    it "is invalid without recipient_id" do
      message = Message.new(user: sender, room: room, subject: "件名", body: "本文")
      expect(message).not_to be_valid
      expect(message.errors[:recipient_id]).to be_present
    end

    it "is invalid when recipient does not exist" do
      message = Message.new(user: sender, recipient_id: 9999, room: room, subject: "件名", body: "本文")
      expect(message).not_to be_valid
      expect(message.errors[:recipient_id]).to be_present
    end

    it "is invalid when sending to self" do
      message = Message.new(user: sender, recipient: sender, room: room, subject: "件名", body: "本文")
      expect(message).not_to be_valid
      expect(message.errors[:recipient_id]).to be_present
    end

    it "is invalid when room does not exist" do
      message = Message.new(user: sender, recipient: recipient, room_id: 9999, subject: "件名", body: "本文")
      expect(message).not_to be_valid
      expect(message.errors[:room_id]).to be_present
    end
  end

  describe "instance methods" do
    it "marks message as read when viewed by recipient" do
      message = Message.create!(user: sender, recipient: recipient, room: room, subject: "件名", body: "本文", read: false)
      message.mark_as_read_by(recipient)
      expect(message.read).to be true
    end

    it "does not mark as read when viewed by sender" do
      message = Message.create!(user: sender, recipient: recipient, room: room, subject: "件名", body: "本文", read: false)
      message.mark_as_read_by(sender)
      expect(message.read).to be false
    end

    it "returns uuid in to_param" do
      message = Message.create!(user: sender, recipient: recipient, room: room, subject: "件名", body: "本文")
      expect(message.to_param).to eq(message.uuid)
    end
  end
end
