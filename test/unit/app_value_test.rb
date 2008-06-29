require File.dirname(__FILE__) + '/../test_helper'

class AppValueTest < ActiveSupport::TestCase
  
  def test_get_export_formats
    assert_equal(export_formats,  AppValue.export_formats)
    assert_equal(export_formats.collect {|ef| ef.name},
      AppValue.export_formats.collect{ |ef| ef.name })
    assert_equal(export_formats.collect {|ef| ef.id},
      AppValue.export_formats.collect{ |ef| ef.id })    
  end
  
  def test_get_packaging_formats
    assert_equal(packaging_formats,  AppValue.export_packaging_formats)
    assert_equal(packaging_formats.collect {|pf| pf.name},
      AppValue.export_packaging_formats.collect{ |pf| pf.name })
    assert_equal(packaging_formats.collect {|pf| pf.id},
      AppValue.export_packaging_formats.collect{ |pf| pf.id })        
  end  
  
  def test_explicite_primary_key
    old_pks = []  
    added_pks = [333, 444, 445, 446]
    old_values = AppValue.find(:all, :conditions => "dict_id = #{RailsdbConfig::Dictionary.export_format}")
    old_values.each {|ov| old_pks << ov.id}
    old_pks_size = old_pks.size
    i = 0
    added_pks.each do |pk|
      AppValue.create( :pk => pk,
                  :dict_id => RailsdbConfig::Dictionary.export_format,
                  :name => pk.to_s + '_name',
                  :desc => pk.to_s + '_desc',
                  :code => pk.to_s + 'code' )
      i +=1                
      assert_equal(old_pks_size + i,
        AppValue.count(:conditions => "dict_id = #{RailsdbConfig::Dictionary.export_format}"))
    end
    new_values = AppValue.find(:all, :conditions => "dict_id = #{RailsdbConfig::Dictionary.export_format}")
    new_pks = []
    new_values.each {|nv| new_pks << nv.id}
    old_and_added_pks = old_pks + added_pks
    old_and_added_pks.each do |onv|
      assert new_pks.include?(onv)
    end
  end
  
  private
  
  def export_formats
    [app_values(:csv), app_values(:tsv), app_values(:yaml)]
  end
  
  def packaging_formats
    [app_values(:zip), app_values(:bzip2), app_values(:tgz)]
  end
end
