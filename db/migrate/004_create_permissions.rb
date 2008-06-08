class CreatePermissions < ActiveRecord::Migration
  
  def self.up
    create_table :permissions, :force => true do |t|
      t.column :name,         :string, :null => false,  :limit => 32
      t.column :description,  :string,                  :limit => 255
      t.timestamps
    end
    add_index :permissions, :name, :unique => true
    Permission.create( :name => 'admin',  :description => 'required for using admin functions' )
    Permission.create( :name => 'user',   :description => 'required for using any functions' )
  end

  def self.down
    drop_table :permissions
  end
  
end
