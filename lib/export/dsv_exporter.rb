require 'csv'

# Delimiter-separated values exporter.
class DsvExporter
  attr_accessor :header
  attr_reader :delimiter
  
  def initialize(delimiter)
    @delimiter = delimiter
  end
  
  def export(rows)
    export_as_text(rows).split($/)
  end
  
  def export_as_text(rows)
    result = ''
    result << CSV.generate_line(@header, @delimiter) << $/ if @header
    rows.each do |row|
      result << CSV.generate_line(row, @delimiter) << $/
    end
    result
  end
  
end
