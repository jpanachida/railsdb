# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

class YamlExporter
  def export_as_text(rows)
    result = ''
    rows.each do |r|
      result << r.to_yaml
    end
    result
  end
end
