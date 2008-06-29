class YamlExporter
  def export_as_text(rows)
    result = ''
    rows.each do |r|
      result << r.to_yaml
    end
    result
  end
end
