
require File.dirname( __FILE__ ) + '/../test_helper'

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

  def test_index_with_user
    user = users( :railsdb )
    db = databases( :sqlite3 )
    get :index, { :id => db.id }, { :user_id => user.id }
    assert_response :success
    assert_template 'index'
  end

  def test_cvs_export
    user = users( :railsdb )
    post :export_table, { :id     => 1,
                          :table  => 'drivers',
                          :fields => { 0 => { header[ 0 ] => '1' },
                                       1 => { header[ 1 ] => '1' } },
                          :app_value => { 'id' => RailsdbConfig::ExportFormat.csv.to_s } },
                        { :user_id => user.id }
    assert_equal driver_export.collect { |e| "#{ e[0] },#{ e[1] }" }.join( $/ ),
                 @response.body
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

end
