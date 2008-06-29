require 'file/file_format'

module DatabaseExport
  def create_export_dir_struct(table_names, tab_format)
    #tmp_path = File.join(RAILS_ROOT, 'tmp', 'export')
    tmp_path = File.join('/', 'tmp', 'railsdb_export')
    dir_name = "#{s_fn(name)}_#{Time.now.to_i}"
    base_path = File.join(tmp_path, dir_name)
    FileUtils.mkpath(base_path)
    table_names.each do |t|
      table = get_table(t) if has_table?(t)
      filename = table.export_table_filename(FileFormat.extension(tab_format), false)
      file = File.new(File.join(base_path, filename), 'w')
      file.puts(table.export_rows(table.fields.collect {|f| f.name}, tab_format))
      file.close
    end
    {:path => base_path, :tmp_path => tmp_path, :dir_name => dir_name}
  end
  
  def create_export_bundle(path, dir_name, pack_format)
    base_path = File.join(path, dir_name)
    file_ext = FileFormat.extension(pack_format)
    case pack_format
    when RailsdbConfig::PackagingFormat.zip.to_s
      `zip -j "#{base_path}.#{file_ext}" #{File.join(base_path, '*')}`
    when RailsdbConfig::PackagingFormat.tgz.to_s
      `tar -C #{path} -czf #{base_path}.#{file_ext} #{dir_name}`
    when RailsdbConfig::PackagingFormat.bzip2.to_s
      `tar -C #{path} -cjf #{base_path}.#{file_ext} #{dir_name}`
    end
    "#{base_path}.#{file_ext}"
  end
  
  def s_fn(filename)
    filename.gsub(/[^\w\.\-]/, '_')
  end
end
