class ApplicationController < ActionController::Base
  include Pundit::Authorization
  require 'csv'
  
  def after_sign_in_path_for(resource)
    mypage_path
  end
  
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?


  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from ActionController::RoutingError, with: :render_404
  rescue_from Exception, with: :render_500

  def render_404
    redirect_to root_path, alert: "ページが見つかりません."
  end

  def render_500
    redirect_to root_path, alert: "エラーが発生しました."
  end

  private
    def sign_in_required
      redirect_to new_user_session_url, alert: "サインインしてください." unless user_signed_in?
    end

  protected
    def configure_permitted_parameters
      added_attrs = [ :email, :name, :password, :password_confirmation ]
      devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
      devise_parameter_sanitizer.permit :account_update, keys: added_attrs
      devise_parameter_sanitizer.permit :sign_in, keys: added_attrs
    end
end
