class CreateAppValues < ActiveRecord::Migration
  
  def self.up
    create_table :app_values, :force => true do |t|
      t.column :dict_id,    :integer, :null => false
      t.column :name,       :string,  :null => false, :limit => 128
      t.column :desc,       :string,  :limit => 255
      t.column :code,       :string,  :limit => 8
      t.column :value_order,      :integer
      t.timestamps
    end 
    
    # Export format
    AppValue.create( :pk => RailsdbConfig::ExportFormat.csv,
                  :dict_id => RailsdbConfig::Dictionary.export_format,
                  :name => 'CSV',
                  :desc => 'Comma Separated Values',
                  :code => 'CSV' )
    AppValue.create( :pk => RailsdbConfig::ExportFormat.tsv,
                  :dict_id => RailsdbConfig::Dictionary.export_format,
                  :name => 'TSV',
                  :desc => 'Tab Separated Values',
                  :code => 'TSV' )
#    AppValue.create( :pk => RailsdbConfig::ExportFormat.xml,
#                  :dict_id => RailsdbConfig::Dictionary.export_format,
#                  :name => 'XML',
#                  :desc => 'Extensible Markup Language',
#                  :code => 'XML' )
    AppValue.create( :pk => RailsdbConfig::ExportFormat.yaml,
                  :dict_id => RailsdbConfig::Dictionary.export_format,
                  :name => 'YAML',
                  :desc => 'YAML Ain\'t a Markup Language',
                  :code => 'YAML' )
#    AppValue.create( :pk => RailsdbConfig::ExportFormat.sql,
#                  :dict_id => RailsdbConfig::Dictionary.export_format,
#                  :name => 'SQL',
#                  :desc => 'Structured Query Language',
#                  :code => 'SQL' )
                
    # Packaging format
    AppValue.create( :pk => RailsdbConfig::PackagingFormat.zip,
                  :dict_id => RailsdbConfig::Dictionary.export_packaging_format,
                  :name => 'Zip',
                  :desc => 'Zip archival format',
                  :code => 'ZIP' )
    AppValue.create( :pk => RailsdbConfig::PackagingFormat.bzip2,
                  :dict_id => RailsdbConfig::Dictionary.export_packaging_format,
                  :name => 'Bzip2',
                  :desc => 'Bzip2 archival format',
                  :code => 'BZIP2' )
    AppValue.create( :pk => RailsdbConfig::PackagingFormat.tgz,
                  :dict_id => RailsdbConfig::Dictionary.export_packaging_format,
                  :name => 'Tgz',
                  :desc => 'Tgz archival format',
                  :code => 'TGZ' )        
  end

  def self.down
    drop_table :app_values
  end
  
end
