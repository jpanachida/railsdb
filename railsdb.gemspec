
Gem::Specification.new do |s|

  s.name              = 'railsdb'
  s.version           = '0.2'
  s.date              = '2008-01-20'
  s.authors           = [ 'Greg Donald' ]
  s.email             = 'gdonald@gmail.com'
  s.homepage          = 'http://railsdb.org/'
  s.summary           = 'RailsDB provides a generic web interface to popular databases.'
  s.description       = 'RailsDB is a web application written in Ruby using the Ruby on Rails web framework. RailsDB provides a generic interface to popular open source databases such as MySQL, PostgreSQL, and SQLite.'
  s.rubyforge_project = 'railsdb'
  s.has_rdoc          = true
  s.rdoc_options      = [ '--main', 'README.txt' ]
  s.extra_rdoc_files  = [ 'README.txt' ]

  s.add_dependency( 'rails', [ '= 2.0.2' ] )

  files = Dir.glob( "#{ File.dirname( __FILE__ ) }/**/*" ).to_a.sort
  s.files = files.delete_if do |f|
    f.include?( '.gem'     ) || \
    f.include?( '.log'     ) || \
    f.include?( '.sqlite3' ) || \
    f.include?( 'doc'      ) || \
    f.include?( 'gemspec'  )
  end
  s.files.each { |f| puts f }

end
