class AppValue < ActiveRecord::Base
  
  def self.export_formats
    find(:all, :select => 'id, name',
      :conditions => ['dict_id = ?', RailsdbConfig::Dictionary.export_format])
  end
  
end
