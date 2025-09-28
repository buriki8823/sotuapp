class UsersController < ApplicationController
  def new
  end

  def mypage
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

private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :avatar)
  end
end
