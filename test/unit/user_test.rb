
require File.dirname( __FILE__ ) + '/../test_helper'

class UserTest < ActiveSupport::TestCase

  fixtures :users

  def test_invalid_user
    user = User.new
    assert !user.valid?
    assert user.errors.invalid?( :fname )
    assert user.errors.invalid?( :lname )
    assert user.errors.invalid?( :email )
    assert user.errors.invalid?( :username )
    assert user.errors.invalid?( :password )
  end

  def test_name_concat
    user = users( :railsdb )
    assert user.fullname == "#{ user.fname } #{ user.lname }"
  end

  def test_has_perm
    user = users( :railsdb )
    assert user.has_perm?( 'admin' )
  end

  def test_has_no_perm
    user = users( :other )
    assert !user.has_perm?( 'admin' )
  end

  def test_password_authentication
    user = users( :railsdb )
    assert_equal user, User.authenticate( user.email, 'changeme' )
    assert_equal user, User.authenticate( user.username, 'changeme' )
    assert_nil User.authenticate( user.username, 'wrong' )
  end

  def test_reset_password
    user = users( :railsdb )
    user.update_attribute( :password, 'something_else' )
    assert_equal user, User.authenticate( user.email, 'something_else' )
  end

  def test_get_rand_pass
    3.times do
      assert User.random_password != User.random_password
    end
  end

end
