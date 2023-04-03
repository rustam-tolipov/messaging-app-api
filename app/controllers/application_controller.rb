class ApplicationController < ActionController::API
  respond_to :json
  before_action :configure_permitted_parameters, if: :devise_controller?

  after_action :set_online

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :email, :password, :password_confirmation])
    devise_parameter_sanitizer.permit(:sign_in, keys: [:email, :password])
  end

  private    

  def set_online
    if current_user
      $redis_onlines.set("user_#{current_user.id}", {
        id: current_user.id,
        last_seen: Time.now,
        username: current_user.username,
      }.to_json)
    end
  end
end
