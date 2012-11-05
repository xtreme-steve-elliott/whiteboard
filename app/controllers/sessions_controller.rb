class SessionsController < ApplicationController
  def create
    session[:logged_in] = true if request.env['omniauth.auth']['info']['email'] =~ /.*@pivotallabs\.com/
    session[:username] = request.env['omniauth.auth']['info']['name']
    redirect_to '/'
  end

  def destroy
    session[:logged_in] = false
  end

  def require_login
  end
end
