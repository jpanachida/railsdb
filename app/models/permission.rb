class Permission < ActiveRecord::Base
  
  has_many :group_permissions
  has_many :permissions, :through => :group_permissions

  validates_presence_of   :name,
                          :message => 'permission name required'
  
end
