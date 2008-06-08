class CreateUserGroups < ActiveRecord::Migration
  
  def self.up
    create_table :user_groups, :force => true do |t|
      t.column :user_id, :int, :null => false
      t.column :group_id, :int, :null => false
      t.timestamps
    end
    add_index :user_groups, [ :user_id, :group_id ], :unique => true, :name => 'user_groups_user_group'
    @railsdb_u = User.find_by_username( 'railsdb' )
    @admin_g  = Group.find_by_name( 'admin' )
    UserGroup.create( :user => @railsdb_u, :group => @admin_g )
  end

  def self.down
    drop_table :user_groups
  end
  
end
