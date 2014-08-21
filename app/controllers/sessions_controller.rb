class SessionsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: :create

  def create
    session[:logged_in] = true if request.env['omniauth.auth']['info']['email'] =~ /.*@pivotal\.io/
    session[:username] = request.env['omniauth.auth']['info']['name']
    redirect_to '/'
  end

  def destroy
    session[:logged_in] = false
  end

  def require_login
  end
end
