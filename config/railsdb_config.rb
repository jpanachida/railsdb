require 'active_support'
 
module RailsdbConfig
    module Dictionary
      mattr_reader :export_format, :export_packaging_format
      @@export_format = 1
      @@export_packaging_format = 2
    end

    module ExportFormat
      mattr_reader :csv, :tsv, :xml, :yaml, :sql
      @@csv = 1
      @@tsv = 2
      @@xml = 3
      @@yaml = 4
      @@sql = 5   
    end
    
    module PackagingFormat
      mattr_reader :zip, :bzip2, :tgz
      @@zip = 6
      @@bzip2 = 7
      @@tgz = 8
    end
end
