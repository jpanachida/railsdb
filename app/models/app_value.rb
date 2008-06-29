class AppValue < ActiveRecord::Base
   
  include ExplicitPrimaryKey
  
  def self.export_formats
    find(:all, :select => 'id, name',
      :conditions => ['dict_id = ?', RailsdbConfig::Dictionary.export_format])
  end
  
  def self.export_packaging_formats
    find(:all, :select => 'id, name',
      :conditions => ['dict_id = ?', RailsdbConfig::Dictionary.export_packaging_format])
  end
 
end
