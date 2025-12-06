class UsersController < ApplicationController
  before_action :authenticate_user!

  def new
  end

  def mypage
   @user = current_user
   @received_star_ratings = StarRating.joins(:post).where(posts: { user_id: @user.id })
   @total_score = @received_star_ratings.sum(:score)
   @average_score = @received_star_ratings.average(:score)&.round(1) || 0
  end

  def show
    @user = User.find_by(uuid: params[:id])
    @received_star_ratings = StarRating.joins(:post).where(posts: { user_id: @user.id })
    @total_score = @received_star_ratings.sum(:score)
    @average_score = @received_star_ratings.average(:score)&.round(1) || 0
  end

  def create
   @user = User.new(user_params)
   if @user.save
    sign_in(@user) # Deviseのログイン処理
    redirect_to root_path, notice: "登録が完了しました"
   else
    render :new
   end
 end

  def update
    @user = current_user

    if params[:user][:mypage_background_url]
      @user.mypage_background_url = params[:user][:mypage_background_url]
    end

    if params[:user][:window_background_url]
      @user.window_background_url = params[:user][:window_background_url]
    end


    if @user.update(user_params)
      redirect_to mypage_users_path, notice: "プロフィールを更新しました"
    else
      render :mypage
    end
  end

  def reset_mypage_background
    current_user.mypage_background_image.purge if current_user.mypage_background_image.attached?
    current_user.update(mypage_background_url: nil)
    redirect_to mypage_users_path, notice: "背景画像をデフォルトに戻しました"
  end

  def reset_window_background
    current_user.window_background_image.purge if current_user.window_background_image.attached?
    current_user.update(window_background_url: nil)
    redirect_to mypage_users_path, notice: "ウィンドウ背景をデフォルトに戻しました"
  end

  def dmpage
    @entries = Entry.where(user_id: current_user.id)
    @messages = Message.where(room_id: params[:room_id]).order(:created_at)

    @focused_message = Message.find_by(uuid: params[:message_id])

    # 宛先ユーザーをビューに渡す
    @recipient = User.find_by(id: @focused_message.recipient_id) if @focused_message

    # メッセージ本体の既読処理
    if @focused_message && @focused_message.recipient_id == current_user.id && !@focused_message.read?
      @focused_message.update(read: true)
    end

    # ★ 返信の既読処理を追加
    if @focused_message
      @focused_message.replies.each do |reply|
        if reply.recipient_id == current_user.id && !reply.read?
          reply.update(read: true)
        end
      end
    end

    # 未読通知の再評価
    @has_new_messages =
      Message.joins("INNER JOIN entries ON entries.room_id = messages.room_id")
             .where(entries: { user_id: current_user.id })
             .where.not(user_id: current_user.id)
             .where(read: false)
             .exists? ||
      Reply.where(recipient_id: current_user.id, read: false).exists?

    @received_messages = Message.includes(:user)
                                .joins("INNER JOIN entries ON entries.room_id = messages.room_id")
                                .where(entries: { user_id: current_user.id })
                                .where.not(user_id: current_user.id)
                                .order(created_at: :desc)

    @sent_messages = Message.includes(:user)
                            .joins("INNER JOIN entries ON entries.room_id = messages.room_id")
                            .where(entries: { user_id: current_user.id })
                            .where(user_id: current_user.id)
                            .order(created_at: :desc)

    @all_messages = (@received_messages + @sent_messages).sort_by(&:created_at).reverse
  end

  def send_message
    recipient = User.find_by(uuid: params[:recipient_id])
    unless recipient
      flash[:alert] = "宛先を選択してください"
      redirect_to newdmpage_user_path(current_user) and return
    end

    room = Room.joins(:entries)
               .where("CAST(entries.user_id AS BIGINT) IN (?)", [ current_user.id, recipient.id ])
               .group("rooms.id")
               .having("COUNT(DISTINCT entries.user_id) = 2")
               .first

    unless room
      room = Room.create!
      Entry.create(user_id: current_user.id, room_id: room.id, partner_id: recipient.id)
      Entry.create(user_id: recipient.id, room_id: room.id, partner_id: current_user.id)
    end

    @message = Message.new(
      user_id: current_user.id,
      room_id: room.id,
      subject: params[:subject],
      body: params[:body],
      recipient_id: recipient.id,
      read: false
    )

    if @message.save
      redirect_to user_dmpage_path(current_user, room_id: room.id)
    else
      @all_users = User.where.not(id: current_user.id)
      flash.now[:alert] = @message.errors.full_messages.join(", ")
      render :newdmpage
    end
  end

  def newdmpage
    @user = current_user
    @all_users = User.where.not(id: @user.id)
  end

  def search
    users = User.where("name LIKE ?", "%#{params[:q]}%")
    render json: users.select(:uuid, :name)
  end

  def reply
    Rails.logger.debug "=== replyアクション開始 ==="
    Rails.logger.debug "params: #{params.inspect}"

    @message = Message.find_by(uuid: params[:id])
    Rails.logger.debug "message: #{@message&.uuid}"


    recipient = User.find_by(uuid: params[:recipient_uuid])
    Rails.logger.debug "recipient_uuid param: #{params[:recipient_uuid]}"
    Rails.logger.debug "recipient: #{recipient&.id}"


    unless recipient
      redirect_to user_dmpage_path(current_user, message_id: @message.uuid),
                  alert: "宛先が指定されていません" and return
    end

    @reply = @message.replies.create(
      user: current_user,
      body: params[:body],
      recipient_id: recipient.id,
      read: false
    )
    Rails.logger.debug "reply作成: recipient_id=#{@reply.recipient_id}, body=#{@reply.body}"


    # ★ 未読通知の再計算
    @has_new_messages = Message.joins("INNER JOIN entries ON entries.room_id = messages.room_id")
                               .where(entries: { user_id: current_user.id })
                               .where.not(user_id: current_user.id)
                               .where(read: false)
                               .exists?

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to user_dmpage_path(current_user, message_id: @message.uuid) }
    end
  end

private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :avatar, :window_background_image, :mypage_background_image, :avatar_url, :mypage_background_url, :window_background_url)
  end
end
