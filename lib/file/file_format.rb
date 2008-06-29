class FileFormat
  def self.mime_type(format)
    case format
      when RailsdbConfig::ExportFormat.csv.to_s       then 'text/csv'
      when RailsdbConfig::ExportFormat.tsv.to_s       then 'text/tab-separated-values'
      when RailsdbConfig::ExportFormat.yaml.to_s      then 'text/yaml'
      when RailsdbConfig::PackagingFormat.zip.to_s    then 'application/zip'
      when RailsdbConfig::PackagingFormat.tgz.to_s    then 'application/x-gzip'
      when RailsdbConfig::PackagingFormat.bzip2.to_s  then 'application/x-bzip'        
      else 'application/octet-stream'
    end
  end
  
  def self.extension(format)
    case format
      when RailsdbConfig::ExportFormat.csv.to_s       then 'csv'
      when RailsdbConfig::ExportFormat.tsv.to_s       then 'tsv'
      when RailsdbConfig::ExportFormat.yaml.to_s      then 'yml'
      when RailsdbConfig::PackagingFormat.zip.to_s    then 'zip'
      when RailsdbConfig::PackagingFormat.tgz.to_s    then 'tar.gz'
      when RailsdbConfig::PackagingFormat.bzip2.to_s  then 'tar.bz2'
      else ''
    end
  end  
end
