
require File.dirname( __FILE__ ) + '/../test_helper'

require 'mocha'

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

  def test_sanitize_filenames
    table = @db_sqlite.get_table('drivers')
    weird_filenames.each do |fn|
      assert_equal(fn[0], @db_sqlite.s_fn(fn[1]))
      assert_equal(fn[0], table.s_fn(fn[1]))
    end
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

  def test_database_create_export_dir_struct
    @db_sqlite.expects( :create_export_dir_struct ).with(['drivers'], RailsdbConfig::ExportFormat.csv).
      returns({:path => '/tmp_path/dir_name', :tmp_path => 'tmp_path', :dir_name => 'dir_name'})
    assert_equal( {:path => File.join('/tmp_path', 'dir_name'), :tmp_path => 'tmp_path', :dir_name => 'dir_name'},
      @db_sqlite.create_export_dir_struct(['drivers'], RailsdbConfig::ExportFormat.csv) )
  end
  
  def test_database_create_export_bundle
    @db_sqlite.expects( :create_export_bundle ).with('/path', 'dir_name', RailsdbConfig::PackagingFormat.zip).
      returns('/path/dir_name.zip')
    assert_equal("#{File.join('/path', 'dir_name')}.#{FileFormat.extension(RailsdbConfig::PackagingFormat.zip)}",
      @db_sqlite.create_export_bundle( '/path', 'dir_name', RailsdbConfig::PackagingFormat.zip ) )
  end
  
  def test_export_table_filename
    @db_sqlite.tables.each do |t|
      table = @db_sqlite.get_table(t.name)
      tab_name = table.name
      db_name = table.database.name
      extensions.each do |ext|
        assert_equal("#{db_name}_#{tab_name}#{ext[0]}",
          table.export_table_filename(ext[1], false))
        assert_match(/#{db_name}_#{tab_name}_\d{10}#{ext[0]}/,
          table.export_table_filename(ext[1], true))
      end
    end
  end

  def test_table_csv_export_rows
    table = @db_sqlite.get_table('drivers')
    assert_equal driver_export.collect { |e| "#{ e[0] },#{ e[1] }" }.join( $/ ),
      table.export_rows(header.flatten, RailsdbConfig::ExportFormat.csv)
  end

  def test_table_tsv_export_rows
    table = @db_sqlite.get_table('drivers')
    assert_equal driver_export.collect { |e| "#{ e[0] }\t#{ e[1] }" }.join( $/ ),
      table.export_rows(header.flatten, RailsdbConfig::ExportFormat.tsv)
  end

  def test_table_yaml_export_rows
    table = @db_sqlite.get_table('drivers')
    assert_equal driver_data.collect { |e| e.to_yaml }.to_s,
      table.export_rows(header.flatten, RailsdbConfig::ExportFormat.yaml)
  end

  private

  def weird_filenames
    [ ['_a_','|a|'], ['a_a','a/a'], ['__a__','??a??'],
      ['____________','|\?*<":>+[]/'], ['_abc___cba_','#abc?/|cba&'],
      ['xyz.uoy','xyz.uoy'], ['.tyz.uoy.','.tyz.uoy.'], ['-.-','-.-'] ]
  end

  def extensions
    [ ['.csv','csv'], ['.a','a'], ['.',''], ['',nil] ]
  end

  def export_formats
    [ RailsdbConfig::ExportFormat.csv, RailsdbConfig::ExportFormat.tsv,
      RailsdbConfig::ExportFormat.yaml.to_s ]
  end

  def driver_export
    header + driver_data
  end

  def driver_data
    [[ drivers( :sqlite3    ).id, drivers( :sqlite3    ).name ],
      [ drivers( :mysql      ).id, drivers( :mysql      ).name ],
      [ drivers( :postgresql ).id, drivers( :postgresql ).name ],
      [ drivers( :oracle     ).id, drivers( :oracle     ).name ] ]
  end

  def header
    [%w( id name )]
  end

end
