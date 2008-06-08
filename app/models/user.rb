require 'digest/sha1'

class User < ActiveRecord::Base

  has_many    :user_groups
  has_many    :groups, :through => :user_groups

  attr_accessor :password_confirmation

  validates_presence_of     :fname,
                            :message => 'first name required'

  validates_presence_of     :lname,
                            :message => 'last name required'

  validates_presence_of     :username,
                            :message => 'last name required'

  validates_format_of       :email,
                            :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
                            :message => 'valid email required'

  validates_uniqueness_of   :email,
                            :message => 'unique email required'

  validates_presence_of     :password,
                            :message => 'password required'

  validates_confirmation_of :password,
                            :message => 'password confirmation required'

  # Both of them, together
  def fullname
    "#{ self.fname } #{ self.lname }"
  end

  # Find permission by iterating over group permissions
  def has_perm?( perm )
    permission = Permission.find_by_name( perm )
    raise "#{perm} not found" if permission.nil?
    groups.each do |g|
      g.permissions.each do |p|
        return true if p.id == permission.id
      end
    end
    return false
  end

  # Authenticate against the database
  def self.authenticate( username, password )
    @user = User.find( :first, :conditions => [ 'username = ?', username ] )
    if @user.nil?
      @user = User.find( :first, :conditions => [ 'email = ?', username ] )
    end
    return nil if @user.nil?
    return @user if User.hash_password( password, @user.passwd_salt ) == @user.passwd_hash
    nil
  end

  # Convenience method
  def password
    @password
  end

  # Setter method assigning a new password.  Re-salts automatically.
  def password=( passwd )
    @password = passwd
    return if passwd.blank?
    self.passwd_salt = User.salt
    self.passwd_hash = User.hash_password( @password, self.passwd_salt )
  end

  private

  def self.salt
    Digest::SHA1.hexdigest( rand.to_s )
  end

  def self.hash_password( password, salt )
    Digest::SHA1.hexdigest( password + salt )
  end

  def self.random_password
    c = %w( b c d f g h j k l m n p qu r s t v w x z ) +
        %w( ch cr fr nd ng nk nt ph pr rd sh sl sp st th tr )
    v = %w( a e i o u y )
    f, r = true, ''
    6.times do
      r << ( f ? c[ rand * c.size ] : v[ rand * v.size ] )
      f = !f
    end
    2.times do
      r << ( rand( 9 ) + 1 ).to_s
    end
    r
  end

end
