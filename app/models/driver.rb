class Driver < ActiveRecord::Base
  
  has_many :databases
  
  validates_presence_of :name,
                        :message => 'name required'

end
