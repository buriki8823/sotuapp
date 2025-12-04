class MessagesController < ApplicationController
  def reply
    @message = Message.find_by(uuid: params[:id])
    recipient = User.find_by(uuid: params[:recipient_id])

    unless recipient
      redirect_to user_dmpage_path(current_user, message_id: @message.uuid),
                  alert: "宛先が指定されていません" and return
    end

    @reply = @message.replies.create(
      user: current_user,
      body: params[:body],
      recipient_id: recipient.id
    )

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to user_dmpage_path(current_user, message_id: @message.uuid) }
    end
  end

  def show
    @focused_message = Message.find_by(uuid: params[:message_id])

    if @focused_message&.user_id == current_user.id && !@focused_message.read?
      @focused_message.update(read: true)
    end
  end
end