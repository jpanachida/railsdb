
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
    @db_sqlite.tables.each do |t|
      table = @db_sqlite.get_table(t.name)
      assert_equal t.name, table.name
      assert_equal t.driver, table.driver
      assert_equal t.database, table.database
    end
  end

  def test_get_no_existing_table
    assert_nil @db_sqlite.get_table('x_not_existing_table_x')
  end

  def test_sanitize_filenames
    table = @db_sqlite.get_table('drivers')
    weird_filenames.each do |fn|
      assert_equal(fn[0], @db_sqlite.s_fn(fn[1]))
      assert_equal(fn[0], table.s_fn(fn[1]))
    end
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
