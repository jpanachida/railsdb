class Row < ActiveRecord::Base
  
  include Comparable
  include Switch
  
  attr_accessor :database
  attr_accessor :table
  attr_accessor :id
  
  #
  # This method assigns the table, id, and database attributes
  #
  def initialize( table, id )
    self.table    = table
    self.id       = id
    self.database = self.table.database
  end
  
  #
  # This is our obligation to Comparable.  Order by id for now
  #
  def <=>( other )
    self.id <=> other.id
  end
  
end
