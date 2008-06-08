EDITOR_LIB_HOME = File.expand_path(File.dirname(__FILE__) + "/../")
require "rubygems"
require "rake/gempackagetask"
class RailsDB
  attr_accessor :rails_root
  def initialize(args = {:rails_root => ENV['PWD']})
    @rails_root = args[:rails_root]
  end

  def create
    rails_home = EDITOR_LIB_HOME + "/rails"
    files = FileList[rails_home + "/**/*"].to_a 
    files += FileList[rails_home + "/.vim/**/*"]
    files += [rails_home + "/.vimrc",rails_home + "/config/.screenrc.code.erb"]
    files.to_a.each do |editor_file|
      save_dir = @rails_root + File.dirname(editor_file.split(rails_home)[1])
      if FileTest.directory?(editor_file)
        if not File.exists?(save_dir)
          puts 'Dir.mkdir("' + save_dir + '")'
          Dir.mkdir(save_dir)
        end
        next
      end
      if not File.exists?(save_dir) or not FileTest.directory?(save_dir)
          puts "Dir.mkdir(" + save_dir + ") "
          Dir.mkdir(save_dir) 
      end
      puts "File.cp(" + editor_file + "," + save_dir  + "/" + File.basename(editor_file) +  ") "
      File.cp(editor_file,save_dir  + "/" + File.basename(editor_file)) 
    end
    if File.exists? editor_script = @rails_root + "/script/editor"
      File.chmod(0755,editor_script) 
    end
    puts "**************************************************************"
    puts "** RailsDB Installed, railsdb <name> to install an instance **"
    puts "**************************************************************"
  end
end
