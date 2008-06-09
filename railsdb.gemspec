Gem::Specification.new do |s|
  s.name = "railsdb"
  s.version = "0.2"
  s.date = "2008-01-20"
  s.summary = "RailsDB provides a generic web interface to popular databases."
  s.email = "gdonald@gmail.com"
  s.homepage = "http://railsdb.org/"
  s.description = "RailsDB is a web application written in Ruby using the Ruby on Rails web framework. RailsDB provides a generic interface to popular open source databases such as MySQL, PostgreSQL, and SQLite."
  s.has_rdoc = true
  s.authors = ["Greg Donald"]
  s.files = FileList["{app,config,db,lib,log,public,script,test,tmp}/**/*"].to_a + ["README_RAILS.txt", "README.txt", "Rakefile", "railsdb.gemspec", "LICENSE.txt"]
  s.test_files = Filelist["test/**/*"].to_a
  s.rdoc_options = ["--main", "README.txt"]
  s.extra_rdoc_files = ["README.txt"]
  s.add_dependency("rails", [">= 2.0.2"])
end
