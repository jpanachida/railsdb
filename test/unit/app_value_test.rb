require File.dirname(__FILE__) + '/../test_helper'

class AppValueTest < ActiveSupport::TestCase
  
  def test_get_export_formats
    assert_equal(export_formats,  AppValue.export_formats)
  end
  
  private
  def export_formats
    [app_values(:csv), app_values(:tsv)]
  end
end
