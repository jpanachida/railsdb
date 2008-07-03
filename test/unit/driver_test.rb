
require File.dirname( __FILE__ ) + '/../test_helper'

class DriverTest < ActiveSupport::TestCase

  def test_invalid
    driver = Driver.new
    assert !driver.valid?
    assert driver.errors.invalid?( :name )
  end

  def test_name_length
    driver = Driver.new( :name => 'x' * 17 )
    assert !driver.valid?
    assert driver.errors.invalid?( :name )
  end

end
