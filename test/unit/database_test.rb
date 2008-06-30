
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
    tables.each { |t| assert @db_sqlite.has_table?( t.name ) }
  end

  def test_has_no_existing_table
    assert !@db_sqlite.has_table?( 'x_not_existing_table_x' )
  end

  def test_get_table
    tables = @db_sqlite.tables
    tables.each do |t|
      table = @db_sqlite.get_table( t.name )
      assert_equal t.name,     table.name
      assert_equal t.driver,   table.driver
      assert_equal t.database, table.database
    end
  end

  def test_get_no_existing_table
    assert_nil @db_sqlite.get_table( 'x_not_existing_table_x' )
  end

  def test_delete_row
    table = @db_sqlite.get_table( 'drivers' )
    count = table.row_count
    table.del_row( 4 )
    assert table.row_count < count
  end

  def test_update_row
    table = @db_sqlite.get_table( 'drivers' )
    row = table.find( :all, :conditions => [ 'id = 3' ] ).first
    table.update_row( row['id'], :name => "altered_#{ row['name'] }" )
    altered = table.find( :all, :conditions => [ 'id = 3' ] ).first
    assert_not_equal row['name'], altered['name']
  end

  def test_add_del_fields
    table = @db_sqlite.get_table( 'drivers' )
    assert !table.has_field?( 'foobar' )
    table.add_field( 'foobar', :string, :limit => 255 )
    assert table.has_field?( 'foobar' )
    table.del_field( 'foobar' )
    assert !table.has_field?( 'foobar' )
  end

  def test_add_fields
#    table = @db_sqlite.get_table( 'drivers' )
#    assert !table.has_field?( 'foo' )
#    assert !table.has_field?( 'bar' )
#    params = { :fields => { 1 => { :name  => 'foo',
#                                   :type  => 'string',
#                                   :limit => 255 },
#                            2 => { :name  => 'bar',
#                                   :type  => 'string',
#                                   :limit => 255 } } }
#    table.add_fields( params )
#    assert table.has_field?( 'foo' )
#    assert table.has_field?( 'bar' )
  end

end
