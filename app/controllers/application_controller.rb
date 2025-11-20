class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!, unless: :devise_controller?
  before_action :set_new_message_flag
  before_action :redirect_to_custom_domain


  def after_sign_in_path_for(resource)
    authenticated_root_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:avatar_url])
    devise_parameter_sanitizer.permit(:account_update, keys: [:avatar_url])
  end

  def set_new_message_flag
    if user_signed_in?
      @has_new_messages = Message.joins("INNER JOIN entries ON entries.room_id = messages.room_id")
                                  .where(entries: { user_id: current_user.id })
                                  .where.not(user_id: current_user.id)
                                  .where(read: false)
                                  .exists?
    end
  end

  def redirect_to_custom_domain
    if request.host == "sotuapp-v2.fly.dev"
      redirect_to "https://pcpack-app.com#{request.fullpath}", status: :moved_permanently
    end
  end
end
