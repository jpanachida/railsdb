
require File.dirname( __FILE__ ) + '/../test_helper'

require 'mocha'

class DatabaseControllerTest < ActionController::TestCase

  include Switch

  fixtures :users,
           :databases,
           :drivers

  self.use_transactional_fixtures = false

  def setup
    @controller = DatabaseController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index_redirect
    get :index
    assert_redirected_to :controller => :login
    assert_equal 'please login', flash[:notice]
  end

# TODO bring it back
#  def test_index_with_user
#    user = users( :railsdb )
#    db = databases( :sqlite3 )
#    get :index, { :id => db.id }, { :user_id => user.id }
#    assert_response :success
#    assert_template 'index'
#  end

  def test_cvs_export
    user = users( :railsdb )
    post :export_table, { :id     => 1,
                          :table  => 'drivers',
                          :fields => { 0 => { header[ 0 ] => '1' },
                                       1 => { header[ 1 ] => '1' } },
                          :file_format => { 'id' => RailsdbConfig::ExportFormat.csv.to_s } },
                        { :user_id => user.id }
    assert_equal FileFormat.mime_type(RailsdbConfig::ExportFormat.csv), @response.headers['type']
    assert_equal driver_export.collect { |e| "#{ e[0] },#{ e[1] }" }.join( $/ ),
                 @response.body
  end

  def test_export_without_selected_rows
    user = users( :railsdb )
    post :export_table, { :id     => 1,
                          :table  => 'drivers',
                          :fields => { }, # No fields selection
                          :file_format => { 'id' => RailsdbConfig::ExportFormat.csv.to_s } },
                        { :user_id => user.id }
    assert_redirected_to(:controller => :database, :action => :table)
    assert_equal 'Select fields to export', flash[:notice]
  end

  def test_export_table_without_data
    user = users( :railsdb )
    AppValue.delete_all
    post :export_table, { :id     => 1,
                          :table  => 'app_values',
                          :fields => { 0 => { header[ 0 ] => '1' },
                                       1 => { header[ 1 ] => '1' } },
                          :file_format => { 'id' => RailsdbConfig::ExportFormat.csv.to_s } },
                        { :user_id => user.id }
    assert_equal FileFormat.mime_type(RailsdbConfig::ExportFormat.csv), @response.headers['type']
    assert_equal "#{header[0]},#{header[1]}", @response.body
  end

  def test_export_table_failed
    user = users( :railsdb )
    Table.any_instance.stubs( :export_rows ).raises(StandardError)
    post :export_table, { :id     => 1,
                          :table  => 'app_values',
                          :fields => { 0 => { header[ 0 ] => '1' },
                                       1 => { header[ 1 ] => '1' } },
                          :file_format => { 'id' => RailsdbConfig::ExportFormat.csv.to_s } },
                        { :user_id => user.id }
    assert_redirected_to(:controller => :database, :action => :table)
    assert_equal 'Could not create export file', flash[:notice]
  end

  def test_export_database
    user = users( :railsdb )
    post :export_database, { :id     => 1,
                             :table  => 'app_values',
                             :table_sel => { 0 => { database_export_tables[ 0 ] => '1' } },
                             :file_format => { 'id' => RailsdbConfig::ExportFormat.csv.to_s },
                             :packaging_format => {'id' => RailsdbConfig::PackagingFormat.zip.to_s} },
                           { :user_id => user.id }
    assert_equal( FileFormat.mime_type(RailsdbConfig::PackagingFormat.zip), @response.headers['type'] )
    assert_not_nil( @response )
    assert_kind_of( Proc, @response.body )
  end

  def test_export_database_without_selected_rows
    user = users( :railsdb )
    post :export_database, { :id     => 1,
                             :table  => 'app_values',
                             :table_sel => { }, # No table selection
                             :file_format => { 'id' => RailsdbConfig::ExportFormat.csv.to_s },
                             :packaging_format => {'id' => RailsdbConfig::PackagingFormat.zip.to_s} },
                           { :user_id => user.id }
    assert_redirected_to(:controller => :database, :action => :index)
    assert_equal 'Select tables to export', flash[:notice]
  end

  def test_export_database_failed
    user = users( :railsdb )
    Database.any_instance.stubs( :create_export_dir_struct ).raises(StandardError)
    post :export_database, { :id     => 1,
                             :table  => 'app_values',
                             :table_sel => { 0 => { database_export_tables[ 0 ] => '1' } },
                             :file_format => { 'id' => RailsdbConfig::ExportFormat.csv.to_s },
                             :packaging_format => {'id' => RailsdbConfig::PackagingFormat.zip.to_s} },
                           { :user_id => user.id }
    assert_redirected_to( :controller => :database, :action => :index )
    assert_match( /Could not create export file/, flash[:notice] )
  end

  def test_create_delete_table
    user = users( :railsdb )
    database = databases( :sqlite3 )
    new_table_name = 'new_test_table'
    post :add_table, { :id => database.id,
                       :name => new_table_name,
                       :add_id => 1,
                       :fields => { '1' => { :name => 'id',
                                             :type => 'primary_key',
                                             :null => '0',
                                             :default => '',
                                             :limit => '',
                                             :scale => '',
                                             :precision => '' },
                                    '2' => { :name => 'name',
                                             :type => 'string',
                                             :null => '0',
                                             :default => '',
                                             :limit => '',
                                             :scale => '',
                                             :precision => '' } } },
                     { :user_id => user.id }
    table_names = database.tables.collect{ |t| t.name }
    table_names_size_before = table_names.size
    assert( table_names.include?( new_table_name ) )
    post :del_table, { :id => 1,
                       :table => new_table_name}
    assert_equal( table_names_size_before - 1, database.tables.size )
    table_names_after_deletion = database.tables.collect{ |t| t.name }
    assert( !table_names_after_deletion.include?( new_table_name ) )
  end

  def test_create_table_without_fields
    user = users( :railsdb )
    database = databases( :sqlite3 )
    new_table_name = 'new_test_table'
    post :add_table, { :id => database.id,
                       :name => new_table_name,
                       :add_id => 1,
                       :fields => { '1' => { :name => '',
                                             :type => '',
                                             :null => '0',
                                             :default => '',
                                             :limit => '',
                                             :scale => '',
                                             :precision => '' } } },
                     { :user_id => user.id }
    table_names = database.tables.collect{ |t| t.name }
    table_names_size_before = table_names.size
    assert( !table_names.include?( new_table_name ) )
    assert_equal( table_names_size_before, database.tables.size )
    assert_select( 'span.error', 'at least one field required' )
  end

  def test_create_table_with_invalid_type
    user = users( :railsdb )
    database = databases( :sqlite3 )
    new_table_name = 'new_test_table'
    post :add_table, { :id => database.id,
                       :name => new_table_name,
                       :add_id => 1,
                       :fields => { '1' => { :name => 'id',
                                             :type => 'invalid_type',
                                             :null => '0',
                                             :default => '',
                                             :limit => '',
                                             :scale => '',
                                             :precision => '' } } },
                     { :user_id => user.id }
    table_names = database.tables.collect{ |t| t.name }
    table_names_size_before = table_names.size
    assert( !table_names.include?( new_table_name ) )
    assert_equal( table_names_size_before, database.tables.size )
    assert_select( 'span.error', 'valid field type required' )
  end

  def test_create_table_with_error
    user = users( :railsdb )
    database = databases( :sqlite3 )
    Database.any_instance.stubs( :create_tbl ).raises(RuntimeError)
    new_table_name = 'new_test_table'
    post :add_table, { :id => database.id,
                       :name => new_table_name,
                       :add_id => 1,
                       :fields => { '1' => { :name => 'id',
                                             :type => 'primary_key',
                                             :null => '0',
                                             :default => '',
                                             :limit => '',
                                             :scale => '',
                                             :precision => '' } } },
                     { :user_id => user.id }
    table_names = database.tables.collect{ |t| t.name }
    table_names_size_before = table_names.size
    assert( !table_names.include?( new_table_name ) )
    assert_equal( table_names_size_before, database.tables.size )
    assert_select( 'p.error', /^An error occured:/ )
  end

  private

  def driver_export
    [ [ header[ 0 ],               header[ 1 ] ],
      [ drivers( :sqlite3    ).id, drivers( :sqlite3    ).name ],
      [ drivers( :mysql      ).id, drivers( :mysql      ).name ],
      [ drivers( :postgresql ).id, drivers( :postgresql ).name ],
      [ drivers( :oracle     ).id, drivers( :oracle     ).name ] ]
  end

  def header
    %w( id name )
  end

  def database_export_tables
    %w{ drivers }
  end

end
