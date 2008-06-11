class Row < ActiveRecord::Base

  include Comparable
  include Switch

  attr_accessor :table
  #attr_accessor :id
  attr_accessor :keys

  #
  # This method assigns the table, id, and database attributes
  #
  def initialize( table, keys )
    switch_ar( table.database, table.name ) do |c|
      self << c.find( :first )
    end
  end

  #
  # This is our obligation to Comparable.  Order by id for now
  #
  def <=>( other )
    self.id <=> other.id
  end

end
