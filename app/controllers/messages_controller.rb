class MessagesController < ApplicationController
    def reply
      @message = Message.find(params[:id])
      @reply = @message.replies.create(
        user: current_user,
        body: params[:body],
        recipient_id: params[:recipient_id]
      )

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to user_dmpage_path(current_user, message_id: @message.id) }
      end
    end

    def show
      @focused_message = Message.find(params[:message_id])
      if @focused_message.user_id == current_user.id && !@focused_message.read?
        @focused_message.update(read: true)
      end
    end
end
