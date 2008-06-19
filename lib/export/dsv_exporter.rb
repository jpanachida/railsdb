# Delimiter-separated values exporter.
class DsvExporter
  CRLF = "\r\n"
  attr_accessor :header
  attr_reader :delimiter
  
  def initialize(delimiter)
    @delimiter = delimiter
  end
  
  def export(rows)
    result = []
    result << @header.collect { |e| %{"#{e.to_s.sub('"', '""')}"} }.join(@delimiter) if @header
    rows.each do |row|
      result << row.collect { |e| %{"#{e.to_s.sub('"', '""')}"} }.join(@delimiter)
    end
    result
  end
  
  def export_as_text(rows)
    export(rows).join(CRLF)
  end
  
end
