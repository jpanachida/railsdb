class LoginController < ApplicationController

  filter_parameter_logging :password

  def login
    session[:user_id] = nil
    if request.post?
      user = User.authenticate( params[:login][:username], params[:login][:password] )
      if user
        session[:user_id] = user.id
        uri = session[:uri]
        session[:uri] = nil
        flash[:notice] = 'login successful'
        redirect_to uri || { :controller => 'home' }
      else
        flash[:notice] = 'login failed'
      end
    end
  end

  def logout
    reset_session
    redirect_to :controller => :login
  end

end
