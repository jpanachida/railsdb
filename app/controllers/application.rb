class ApplicationController < ActionController::Base

  helper :all

  protect_from_forgery :secret => '3e1169688926f48ca8731b64a1c3c2126a53404c1527cd97b7db1e87998f4f619b48461c9536a068ac218e6bdb8c551edccbd1c46f82db0b8d7a3f8cced8549c'

  before_filter :get_current_user

  #
  # Find user by session id
  #
  def get_current_user
    unless session[:user_id]
      @current_user = nil
      return
    end
    @current_user = User.find( :first, :conditions => [ 'id = ?', session[:user_id] ] )
  end

  #
  # Checks current logged-in user's permission set for a certain permission
  #
  def check_site_perm( perm )
    return true if @current_user && @current_user.has_perm?( perm )
    false
  end

end
