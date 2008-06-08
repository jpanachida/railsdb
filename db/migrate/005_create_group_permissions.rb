class CreateGroupPermissions < ActiveRecord::Migration
  
  def self.up
    create_table :group_permissions, :force => true do |t|
      t.column :group_id,       :int, :null => false
      t.column :permission_id,  :int, :null => false
      t.timestamps
    end
    add_index :group_permissions, [ :group_id, :permission_id ], :unique => true, :name => 'group_perms_group_perm'
    @admin_g  = Group.find_by_name( 'admin' )
    @user_g   = Group.find_by_name( 'user' )
    @admin_p  = Permission.find_by_name( 'admin' )
    @user_p   = Permission.find_by_name( 'user' )
    GroupPermission.create( :group => @admin_g, :permission => @admin_p )
    GroupPermission.create( :group => @user_g, :permission => @user_p )
  end

  def self.down
    drop_table :group_permissions
  end
  
end
