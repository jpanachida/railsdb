class Driver < ActiveRecord::Base

  has_many :databases

  validates_presence_of :name,
                        :message => 'name required'

  validates_length_of   :name,
                        :maximum => 16,
                        :message => 'must be %d characters or less'

end
