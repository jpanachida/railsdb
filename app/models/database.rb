require 'export/database_export'

class Database < ActiveRecord::Base

  include Switch
  include DatabaseExport

  belongs_to :driver

  validates_presence_of :driver_id,
                        :message    => 'driver type required'

  validates_presence_of :name,
                        :message    => 'name required'

  validates_length_of   :name,
                        :maximum    => 64,
                        :message    => 'must be less than %d characters in length'

  validates_presence_of :description,
                        :message    => 'description required'

  validates_length_of   :description,
                        :maximum    => 255,
                        :message    => 'must be less than %d characters in length'

  validates_presence_of :path,
                        :if         => Proc.new { |database| database.driver && database.driver.name == 'sqlite3' },
                        :message    => 'file path required for sqlite3'

  validates_length_of   :path,
                        :if         => Proc.new { |database| database.driver && database.driver.name == 'sqlite3' },
                        :maximum    => 255,
                        :message    => 'must be less than %d characters in length'

  validates_presence_of :host,
                        :if         => Proc.new { |database| database.driver && database.driver.name != 'sqlite3' },
                        :message    => 'host required'

  validates_length_of   :host,
                        :if         => Proc.new { |database| database.driver && database.driver.name != 'sqlite3' },
                        :maximum    => 255,
                        :message    => 'must be less than %d characters in length'

  validates_presence_of :username,
                        :if         => Proc.new { |database| database.driver && database.driver.name != 'sqlite3' },
                        :message    => 'username required'

  validates_length_of   :username,
                        :if         => Proc.new { |database| database.driver && database.driver.name != 'sqlite3' },
                        :maximum    => 32,
                        :message    => 'must be less than %d characters in length'

  validates_length_of   :password,
                        :allow_nil  => true,
                        :maximum    => 40,
                        :message    => 'must be less than %d characters in length'

  #
  #
  #
  def del_table( table )
    switch( self ) do
      ActiveRecord::Base.connection.drop_table( table.to_sym )
    end
  end

  #
  # This method switches ActiveRecord's connection to the actual
  # database this database model represents, creates a table, then
  # switches back to the RailsDB database.
  #
  # Only the first field is included in the create_table call.  The
  # rest are added using add_column.
  #
  def create_tbl( params )
    switch( self ) do
      options = {}
      options[:id] = false if params[:add_id] == '0'
      col_options = mangle_column_options( params, '1' )
      ActiveRecord::Base.connection.create_table( params[:name].to_sym, options ) do |t|
        t.column params[:fields]['1'][:name].to_sym, params[:fields]['1'][:type].to_sym, col_options
      end
      table = self.get_table( params[:name] )
      table.add_fields( params ) if table
    end
  end

  def get_table( name )
    switch( self ) do
      return Table.new( self, name ) if ActiveRecord::Base.connection.tables.include? name
    end
    nil
  end

  #
  # This method switches ActiveRecord's connection to the actual
  # database this database model represents, grabs a table list,
  # then switches back to the RailsDB database.
  #
  def tables
    tables = []
    switch( self ) do
      ActiveRecord::Base.connection.tables.each do |t|
        tables << Table.new( self, t )
      end
    end
    tables
  end

  #
  # This provides just the table names, not table objects
  #
  def table_names
    self.tables.collect { |t| t.name }
  end

  #
  # Does this database contain a table with passed name?
  #
  def has_table?( name )
    self.table_names.each { |t| return true if t == name }
    false
  end

end
