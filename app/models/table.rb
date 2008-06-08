class Table
  
  include Switch
  
  attr_accessor :database
  attr_accessor :name
  attr_accessor :driver
  
  #
  # Assign the database this table belongs to and it's name
  #
  def initialize( database, name )
    self.database = database
    self.name     = name
    self.driver   = self.database.driver
  end

  #
  # This method switches ActiveRecord's connection to the actual
  # database this database model represents, deletes the field,
  # then switches back to the RailsDB database.
  #
  def del_field( name )
    switch( self.database ) do
      ActiveRecord::Base.connection.remove_column( self.name.to_sym, name.to_sym )
    end
  end

  #
  # This method switches ActiveRecord's connection to the actual
  # database this database model represents, adds the new field,
  # then switches back to the RailsDB database.
  #
  def add_field( name, type, options )
    switch( self.database ) do
      ActiveRecord::Base.connection.add_column( self.name.to_sym, name.to_sym, type.to_sym, options )
    end
  end

  #
  # This method adds fields from the params from a form.
  #
  def add_fields( params )
    1.upto( params[:fields].size ) do |x|
      if params[:fields][x.to_s] && !params[:fields][x.to_s][:name].empty?
        unless self.has_field?( params[:fields][x.to_s][:name] )
          self.add_field( params[:fields][x.to_s][:name],
                          params[:fields][x.to_s][:type],
                          mangle_column_options( params, x.to_s ) )
        end
      end
    end
  end

  #
  # This calls ActiveRecord's create method on the given model class
  #
  def create( args )
    switch_ar( self.database, self.name ) do |c|
      params = {}
      args.collect { |a| { a[0].to_sym => args[ a[0] ] } }.each do |b|
        params[ b.keys.first.to_sym ] = b[ b.keys.first.to_sym ]
      end
      o = c.create( params )
    end
  end

  #
  # This calls ActiveRecord's find method on the given model class
  #
  def find( *args )
    switch_ar( self.database, self.name ) { |c| o = c.find( *args ).collect{ |r| r.attributes } }
  end
  
  #
  # This method gets the row count for this table.
  #
  def row_count
    switch_ar( self.database, self.name ) { |c| o = c.count }
  end

  #
  # Just the field names, sorted
  #
  def field_names
    self.fields.collect { |f| f.name }.sort
  end
  
  #
  # Does this table contain a filed with passed name?
  #
  def has_field?( name )
    self.field_names.each { |f| return true if f == name }
    false
  end
  
  #
  # How many fields in this table
  #
  def field_count
    self.fields.size
  end
  
  #
  # Returns a single field by name
  #
  def get_field( name )
    self.fields.each { |f| return f if f.name == name }
    nil
  end
  
  #
  # This method maps the field attributes for a table into known named
  # keys, required mostly because sqlite doesn't match the others
  #
  def fields
    fields = []
    switch( self.database ) do
      cid = 0
      case self.driver.name
      when 'sqlite3'
        # map sqlite fields to match more common names
        ActiveRecord::Base.connection.table_structure( self.name.to_sym ).each do |c|
          attributes = {}
          attributes[:cid]     = c['cid']
          attributes[:name]    = c['name']
          attributes[:type]    = c['type']
          attributes[:primary] = c['pk']
          attributes[:null]    = c['notnull']
          attributes[:default] = c['dflt_value']
          fields << Field.new( self, attributes )
        end
      else
        # this same mapping currently works for both mysql and postgresql
        ActiveRecord::Base.connection.columns( self.name.to_sym ).each do |c|
          attributes = {}
          attributes[:cid]       = cid
          attributes[:name]      = c.name
          attributes[:type]      = c.type
          attributes[:sql_type]  = c.sql_type
          attributes[:primary]   = c.primary
          attributes[:null]      = c.null
          attributes[:default]   = c.default
          attributes[:scale]     = c.scale
          attributes[:precision] = c.precision
          attributes[:limit]     = c.limit
          fields << Field.new( self, attributes )
          cid += 1
        end
      end
    end
    fields.sort
  end
    
end
