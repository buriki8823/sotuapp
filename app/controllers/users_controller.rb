class UsersController < ApplicationController
  def new
  end

  def mypage
   @user = current_user
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


private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :avatar, :window_background_image, :mypage_background_image, :avatar_url, :mypage_background_url, :window_background_url)
  end
end
