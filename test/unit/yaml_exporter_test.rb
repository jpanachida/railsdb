require File.dirname( __FILE__ ) + '/../test_helper'

require 'test/unit'
require 'export/yaml_exporter'

class YamlExporterTest < Test::Unit::TestCase

  fixtures :app_values
  
  def setup
    @exporter = YamlExporter.new
    @app_values_export = ''
    @app_values = []
    AppValue.find(:all).each do |v|
      @app_values_export << v.attributes.to_yaml
      @app_values << v.attributes
    end
  end
  
  def test_text_export
    assert_equal @app_values_export, @exporter.export_as_text(@app_values)
  end
  
  def test_export_values
    yaml_values = []
    YAML.load_documents(@exporter.export_as_text(@app_values)) do |v|
      yaml_values << v
    end
    assert_equal @app_values.size, yaml_values.size
    for i in 0...(@app_values.size) do
      a_value = @app_values[i]
      y_value = yaml_values[i]
      assert_equal a_value['id'], y_value['id']
      assert_equal a_value['dict_id'], y_value['dict_id']
      assert_equal a_value['name'], y_value['name']
      assert_equal a_value['code'], y_value['code']
    end
  end
end
