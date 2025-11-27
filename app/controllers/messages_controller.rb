class MessagesController < ApplicationController
  def reply
    # UUIDでメッセージを取得
    @message = Message.find_by(uuid: params[:id])

    # recipient_id も UUID 化するなら find_by(uuid: …) に変更が必要
    recipient = User.find_by(uuid: params[:recipient_id])

    @reply = @message.replies.create(
      user: current_user,
      body: params[:body],
      recipient_id: recipient.id # 外部キーがまだ整数idならこのまま
    )

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to user_dmpage_path(current_user, message_id: @message.uuid) }
    end
  end

  def show
    # UUIDでメッセージを取得
    @focused_message = Message.find_by(uuid: params[:message_id])

    if @focused_message&.user_id == current_user.id && !@focused_message.read?
      @focused_message.update(read: true)
    end
  end
end