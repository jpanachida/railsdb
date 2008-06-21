require File.dirname(__FILE__) + '/../test_helper'

class DatabaseControllerTest < ActionController::TestCase
  @@header = ['id', 'name']
  
  self.use_transactional_fixtures = false
  
  def setup
    @controller = DatabaseController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end
  
  def test_cvs_export
    post :export_table, :id => 1, :table => 'drivers',
      :field => {@@header[0] => 1, @@header[1] => 1},
      :app_value => {:id => RailsdbConfig::ExportFormat.csv}
    assert_equal(exported_data.collect { |e| %{#{e[0]},#{e[1]}} }.join($/), @response.body.chomp)
  end
  
  private
  def exported_data
    [[@@header[1],@@header[0]],
      [drivers(:sqlite).name, drivers(:sqlite).id],
      [drivers(:oracle).name, drivers(:oracle).id],
      [drivers(:postgresql).name, drivers(:postgresql).id]]
  end
end
