class Group < ActiveRecord::Base
  
  has_many :user_groups
  has_many :users, :through => :user_groups

  has_many :group_permissions
  has_many :permissions, :through => :group_permissions

  validates_presence_of   :name,
                          :message => 'group name required'

end
