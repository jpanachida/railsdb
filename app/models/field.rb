class Field
  
  include Comparable
  include Switch
  
  attr_accessor :database
  attr_accessor :table
  attr_accessor :attributes
  
  #
  # This method assigns the database and table this field appears in,
  # along with all the attributes, no matter how useless they may be.
  #
  def initialize( table, attributes )
    self.table      = table
    self.attributes = attributes
    self.database   = self.table.database
  end
  
  #
  # This is our obligation to Comparable.  Order by column id
  # (which is faked for some databases).
  #
  def <=>( other ) 
    self.cid <=> other.cid 
  end
  
  #
  # Update the field using the parameters passed.  This first
  # checks the name for an update then operates on the actual
  # field attributes.
  #
  def update( params )
    switch( self.database ) do
      if params['field'] !=  params['fields']['1']['name']
        ActiveRecord::Base.connection.rename_column( self.table.name.to_sym,
                                                     params['field'].to_sym,
                                                     params['fields']['1']['name'].to_sym )
      end
      ActiveRecord::Base.connection.change_column( self.table.name.to_sym,
                                                   params['fields']['1']['name'].to_sym,
                                                   params['fields']['1']['type'].to_sym,
                                                   mangle_column_options( params, '1' ) )
    end
  end
  
  #
  # name mapping
  #
  def name
    self.attributes[:name]
  end
  
  #
  # column id mapping
  #
  def cid
    self.attributes[:cid]
  end

  #
  # not all databases send this
  #
  def sql_type
    self.attributes[:sql_type]
  end

  #
  # field type mapping
  #
  def type
    self.attributes[:type]
  end
  
  #
  # limit mapping
  #
  def limit
    self.attributes[:limit]
  end

  #
  # precision mapping
  #
  def precision
    self.attributes[:precision]
  end

  #
  # scale mapping
  #
  def scale
    self.attributes[:scale]
  end

  #
  # inconsistant on some databases
  #
  def primary
    self.attributes[:primary]
  end
  
  #
  # is null mapping
  #
  def null
    self.attributes[:null]
  end
  
  #
  # default value mapping
  #
  def default
    self.attributes[:default]
  end
  
end