class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    auth = request.env['omniauth.auth']

    @user = User.find_or_initialize_by(provider: auth.provider, uid: auth.uid)
    @user.assign_attributes(
      email: auth.info.email,
      name: auth.info.name, # ← 通常登録と揃える
      avatar_url: auth.info.image, # ← Cloudinaryと揃える
      password: Devise.friendly_token[0, 20]
    )
    @user.save!

    sign_in_and_redirect @user, event: :authentication
  end
end