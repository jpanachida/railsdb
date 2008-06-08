class HomeController < ApplicationController
  
  before_filter :check_perm, :except => [ :login, :logout ]

  filter_parameter_logging :password
  
  layout :get_layout

  def index
  end

  def top
  end

  def menu
  end

  def bottom
  end

  def databases
    @databases = Database.find( :all, :order => 'name' )
  end

  def add_database
    @database = Database.new
    if request.post?
      @database = Database.new( params[:database] )
      @database.save
      unless @database.new_record?
        flash[:notice] = 'new database added'
        redirect_to :controller => 'home', :action => 'databases'
      end
    end
  end

  def edit_database
    get_database params[:id]
    if request.post?
      if @database.update_attributes( params[:database] )
        flash[:notice] = 'database updated'
        redirect_to :controller => 'home', :action => 'databases'
      end
    end
  end

  def del_database
    get_database params[:id]
    if request.post?
      @database.destroy
      flash[:notice] = 'database deleted'
      redirect_to :controller => 'home', :action => 'databases'
    end
  end

  def drivers
    @drivers = Driver.find( :all, :order => 'name' )
  end

  def add_driver
    @driver = Driver.new
    if request.post?
      @driver = Driver.new( params[:driver] )
      @driver.save
      unless @driver.new_record?
        flash[:notice] = 'new driver added'
        redirect_to :controller => 'home', :action => 'drivers'
      end
    end
  end

  def edit_driver
    get_driver params[:id]
    if request.post?
      if @driver.update_attributes( params[:driver] )
        flash[:notice] = 'driver updated'
        redirect_to :controller => 'home', :action => 'drivers'
      end
    end
  end

  def del_driver
    get_driver params[:id]
    if request.post?
      @driver.destroy
      flash[:notice] = 'driver deleted'
      redirect_to :controller => 'home', :action => 'drivers'
    end
  end

  def group_permissions
    get_group params[:id]
    @group_permissions = @group.group_permissions
    pids = @group_permissions.collect { |p| p.permission_id }
    @permissions = []
    Permission.find( :all, :order => 'name' ).each do |p|
      @permissions << p unless pids.include? p.id
    end
  end

  def add_group_permission
    get_group params[:group_id]
    permission = Permission.find( :first, :conditions => [ 'id = ?', params[:permission_id] ] )
    if permission.nil?
      flash[:notice] = 'permission not found'
      redirect_to :controller => 'home', :action => 'group_permissions', :id => @group.id
    end
    if @group.group_permissions.include? permission
      flash[:notice] = 'permission already exists'
    else
      @group.permissions << permission
      flash[:notice] = 'new permission added'
    end
    redirect_to :controller => 'home', :action => 'group_permissions', :id => @group.id
  end

  def del_group_permission
    @group_permission = GroupPermission.find( :first, :conditions => [ 'id = ?', params[:id] ] )
    @group = @group_permission.group
    @permission = @group_permission.permission
    if request.post?
      @group_permission.destroy
      flash[:notice] = 'group permission deleted'
      redirect_to :controller => 'home', :action => 'group_permissions', :id => @group.id
    end
  end

  def user_groups
    get_user params[:id]
    @user_groups = @user.user_groups
    gids = @user_groups.collect { |g| g.group_id }
    @groups = []
    Group.find( :all, :order => 'name' ).each do |g|
      @groups << g unless gids.include? g.id
    end
  end

  def add_user_group
    get_user params[:user_id]
    group = Group.find( :first, :conditions => [ 'id = ?', params[:group_id] ] )
    if group.nil?
      flash[:notice] = 'group not found'
      redirect_to :controller => 'home', :action => 'user_groups', :id => @user.id
    end
    if @user.user_groups.include? group
      flash[:notice] = 'group already exists'
    else
      @user.groups << group
      flash[:notice] = 'new group added'
    end
    redirect_to :controller => 'home', :action => 'user_groups', :id => @user.id
  end

  def del_user_group
    @user_group = UserGroup.find( :first, :conditions => [ 'id = ?', params[:id] ] )
    user = @user_group.user
    if request.post?
      @user_group.destroy
      flash[:notice] = 'user group deleted'
      redirect_to :controller => 'home', :action => 'user_groups', :id => user.id
    end
  end

  def permissions
    @permissions = Permission.find( :all, :order => 'name' )
  end

  def add_permission
    @permission = Permission.new
    if request.post?
      @permission = Permission.new( params[:permission] )
      @permission.save
      unless @permission.new_record?
        flash[:notice] = 'new permission added'
        redirect_to :controller => 'home', :action => 'permissions'
      end
    end
  end

  def edit_permission
    get_permission params[:id]
    if request.post?
      if @permission.update_attributes( params[:permission] )
        flash[:notice] = 'permission updated'
        redirect_to :controller => 'home', :action => 'permissions'
      end
    end
  end

  def del_permission
    get_permission params[:id]
    if request.post?
      @permission.destroy
      flash[:notice] = 'permission deleted'
      redirect_to :controller => 'home', :action => 'permissions'
    end
  end

  def groups
    @groups = Group.find( :all, :order => 'name' )
  end

  def add_group
    @group = Group.new
    if request.post?
      @group = Group.new( params[:group] )
      @group.save
      unless @group.new_record?
        flash[:notice] = 'new group added'
        redirect_to :controller => 'home', :action => 'groups'
      end
    end
  end

  def edit_group
    get_group params[:id]
    if request.post?
      if @group.update_attributes( params[:group] )
        flash[:notice] = 'group updated'
        redirect_to :controller => 'home', :action => 'groups'
      end
    end
  end

  def del_group
    get_group params[:id]
    if request.post?
      @group.destroy
      flash[:notice] = 'group deleted'
      redirect_to :controller => 'home', :action => 'groups'
    end
  end

  def users
    @users = User.find( :all, :order => 'lname,fname' )
  end

  def add_user
    @user = User.new
    if request.post?
      @user = User.new( params[:user] )
      @user.save
      unless @user.new_record?
        flash[:notice] = 'new user added'
        redirect_to :controller => 'home', :action => 'users'
      end
    end
  end

  def edit_user
    get_user params[:id]
    if request.post?
      #TODO: validate the fields below
      @user2 = User.find_by_email( params[:user][:email] )
      if @user2.nil? || @user2.id == @user.id
        @user.update_attribute( 'email', params[:user][:email] )
      end
      @user.update_attribute( 'fname', params[:user][:fname] )
      @user.update_attribute( 'lname', params[:user][:lname] )
      @user.update_attribute( 'username', params[:user][:username] )
      flash[:notice] = 'user updated'
      redirect_to :controller => 'home', :action => 'users'
    end
  end

  def update_pass
    get_user params[:user][:id]
    if request.post?
      #TODO: make password validation work from inside model
      if params[:user][:password] == params[:user][:password_confirmation]
        passwd_salt = User.salt
        @user.update_attribute( 'passwd_salt', passwd_salt )
        passwd_hash = User.hash_password( params[:user][:password], passwd_salt )
        @user.update_attribute( 'passwd_hash', passwd_hash )
        flash[:notice] = 'password updated'
        redirect_to :controller => 'home', :action => 'users'
      else
        @user.errors.add( 'password_confirmation', 'passwords must match' )
      end
    end
  end

  def del_user
    get_user params[:id]
    if request.post?
      @user.destroy
      flash[:notice] = 'user deleted'
      redirect_to :controller => 'home', :action => 'users'
    end
  end

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
    redirect_to :controller => :home, :action => :login
  end

  private

  def check_perm
    unless check_site_perm 'admin'
      flash[:notice] = 'please login'
      redirect_to :controller => 'home', :action => 'login'
    end
  end

  def get_user( id )
    @user = User.find( :first, :conditions => [ 'id = ?', id ] )
    if @user.nil?
      flash[:notice] = 'user not found'
      redirect_to :controller => 'home', :action => 'users'
    end
  end

  def get_group( id )
    @group = Group.find( :first, :conditions => [ 'id = ?', id ] )
    if @group.nil?
      flash[:notice] = 'group not found'
      redirect_to :controller => 'home', :action => 'groups'
    end
  end

  def get_permission( id )
    @permission = Permission.find( :first, :conditions => [ 'id = ?', id ] )
    if @permission.nil?
      flash[:notice] = 'permission not found'
      redirect_to :controller => 'home', :action => 'permissions'
    end
  end
  
  def get_driver( id )
    @driver = Driver.find( :first, :conditions => [ 'id = ?', id ] )
    if @driver.nil?
      flash[:notice] = 'driver not found'
      redirect_to :controller => 'home', :action => 'drivers'
    end
  end
  
  def get_database( id )
    @database = Database.find( :first, :conditions => [ 'id = ?', id ] )
    if @database.nil?
      flash[:notice] = "database &quot;#{ database }&quot; not found";
      redirect_to :controller => :home, :action => :databases
    end
  end

  def get_layout
    ( %w( index top menu bottom login ).include? self.action_name ) ? nil : 'application'
  end
  
end
