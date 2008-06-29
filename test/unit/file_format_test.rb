require File.dirname(__FILE__) + '/../test_helper'
 
require 'file/file_format'

class FileFormatTest < ActiveSupport::TestCase
  def test_mime_types
    mime_types.each do |mt|
      assert_equal(mt[1], FileFormat.mime_type(mt[0]))
    end
  end
  
  def test_unknown_mime_type
    unknown_mime_type = -1
    assert_equal('application/octet-stream', FileFormat.mime_type(unknown_mime_type))
  end
  
  def test_extensions
    extensions.each do |e|
      assert_equal(e[1], FileFormat.extension(e[0]))
    end
  end
  
  def test_unknown_extension
    unknown_extension = -1
    assert_equal('', FileFormat.extension(unknown_extension))
  end
  
  private
  
  def mime_types
    [ [RailsdbConfig::ExportFormat.csv, 'text/csv'],
      [RailsdbConfig::ExportFormat.tsv, 'text/tab-separated-values'],
      [RailsdbConfig::ExportFormat.yaml, 'text/yaml'],
      [RailsdbConfig::PackagingFormat.tgz, 'application/x-gzip'],
      [RailsdbConfig::PackagingFormat.bzip2, 'application/x-bzip'],
      [RailsdbConfig::PackagingFormat.zip, 'application/zip'] ]
  end
  
  def extensions
    [ [RailsdbConfig::ExportFormat.csv, 'csv'],
      [RailsdbConfig::ExportFormat.tsv, 'tsv'],
      [RailsdbConfig::ExportFormat.yaml, 'yml'],
      [RailsdbConfig::PackagingFormat.tgz, 'tar.gz'],
      [RailsdbConfig::PackagingFormat.bzip2, 'tar.bz2'],
      [RailsdbConfig::PackagingFormat.zip, 'zip'] ]    
  end
end
