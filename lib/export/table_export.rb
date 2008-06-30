require 'export/dsv_exporter'
require 'export/yaml_exporter'

module TableExport
  def export_rows(fields, format)
    data = []
    rows = find( :all,
                 :select => fields.join( ',' ),
                 :order  => fields.include?( 'id' ) ? 'id' : fields[ 0 ] )
    rows.each { |r| data << fields.collect{ |f| r[ f ] } }
    case format.to_s
    when RailsdbConfig::ExportFormat.csv.to_s
      delimiter = ','
      exporter = DsvExporter.new( delimiter )
      exporter.header = fields
    when RailsdbConfig::ExportFormat.tsv.to_s
      delimiter = "\t"
      exporter = DsvExporter.new( delimiter )
      exporter.header = fields
    when RailsdbConfig::ExportFormat.yaml.to_s
      exporter = YamlExporter.new
    end
    exporter.export_as_text( data )
  end

  def export_table_filename(ext, include_time = false)
    time = Time.now.to_i
    "#{ s_fn(database.name) }_#{ s_fn(name) }#{ ('_' + time.to_s) if include_time}#{('.' +  ext) if ext }"
  end

  def s_fn(filename)
    filename.gsub(/[^\w\.\-]/, '_')
  end
end
