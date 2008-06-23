
require File.dirname( __FILE__ ) + '/../test_helper'

class DatabaseTest < ActiveSupport::TestCase

  fixtures :databases,
           :drivers

  def test_invalid
    db = Database.new
    assert !db.valid?
    assert db.errors.invalid?( :name )
    assert db.errors.invalid?( :driver_id )
    assert db.errors.invalid?( :description )
  end

  def test_valid_sqlite3
    db = databases( :sqlite3 )
    assert db.valid?
  end

  def test_valid_mysql
    db = databases( :mysql )
    assert db.valid?
  end

  def test_valid_pgsql
    db = databases( :pgsql )
    assert db.valid?
  end

  def test_valid_oracle
    db = databases( :oracle )
    assert db.valid?
  end

end
