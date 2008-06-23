#
# This is a mixin used by any other models that need to do
# work with non- RailsDB application databases.
#
module Switch

  #
  # Switch RailsDB's database connection to a different database.
  #
  # (Add newly discovered broken table names in config/environment.rb.)
  #
  # This is magic:
  #
  def switch_ar( database, name )
    switch( database ) do
      begin
        c = name.singularize.camelize.constantize
      rescue NameError
        klass = Class.new ActiveRecord::Base
        Object.const_set name.singularize.camelize, klass
        klass.set_table_name name
        begin
          c = name.singularize.camelize.constantize
        rescue NameError
          raise "NameError: Cannot constantize #{ name }"
        end
      end
      klass = Class.new ActiveRecord::Base
      class_name = ALT_TABLE_NAMES.include?( name ) ? ALT_TABLE_NAMES[ name ] : name
      unless Object.const_get class_name.singularize.camelize
        Object.const_set class_name.singularize.camelize, klass
      end
      klass.set_table_name name
      yield class_name.singularize.camelize.constantize
    end
  end

  #
  # This method wraps work done to alternate databases
  #
  def switch( database )
    switch_db( database )
    begin
      begin
        yield
      rescue  ArgumentError
        raise "Argument error: #{ $!.to_s }"
      rescue ActiveRecord::StatementInvalid
        raise "#{ $!.to_s }"
      rescue Mysql::Error, NameError, PGError, TypeError
        raise "Database Error: #{ $!.to_s }"
      ensure
        switch_back
      end
    rescue NameError

    ensure
      switch_back
    end
  end

  #
  # This method establishes a new ActiveRecord connection using
  # the database passed.  If you call this you need to finish by
  # calling switch_back.
  #
  def switch_db( database )
    options = { :adapter  => database.driver.name }
    case database.driver.name
      when  'sqlite3'
        options[:database] = database.path
      when  'mysql',
            'postgresql',
            'oracle'
        options[:database] = database.name
        options[:host]     = database.host
        options[:username] = database.username
        options[:password] = database.password
      else
        raise "#{ database.driver.name } driver not available"
    end
    ActiveRecord::Base.establish_connection( options )
  end

  #
  # This method is used to re-establish the RailsDB application
  # database.  It's usually called after a call to switch_db.
  #
  def switch_back
    ActiveRecord::Base.establish_connection( RAILS_ENV.to_sym )
  end

end
