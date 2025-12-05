class Users::PasswordsController < Devise::PasswordsController
  protected

  def after_resetting_password_path_for(resource)
    sign_out(resource) # 自動ログインを防ぐ
    new_session_path(resource_name) # ログイン画面に遷移
  end
end
