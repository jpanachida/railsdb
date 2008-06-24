
require File.dirname( __FILE__ ) + '/../test_helper'

class DatabaseTest < ActiveSupport::TestCase

  self.use_transactional_fixtures = false
  
  fixtures :databases,
           :drivers

  def setup
    @db_sqlite = databases( :sqlite3 )
  end
  
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
  
  def test_has_table
    tables = @db_sqlite.tables
    tables.each { |t| assert @db_sqlite.has_table?(t.name) }
  end
  
  def test_has_no_existing_table
    assert !@db_sqlite.has_table?('x_not_existing_table_x')
  end
  
  def test_get_table
    tables = @db_sqlite.tables
    tables.each do |t|
      table = @db_sqlite.get_table(t.name)
      assert_equal t.name, table.name
      assert_equal t.driver, table.driver
      assert_equal t.database, table.database
    end
  end
  
  def test_get_no_existing_table
    assert_nil @db_sqlite.get_table('x_not_existing_table_x')
  end
 
end
