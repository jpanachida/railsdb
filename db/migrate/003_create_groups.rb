class CreateGroups < ActiveRecord::Migration
  
  def self.up
    create_table :groups, :force => true do |t|
      t.column :name, :string, :null => false, :limit => 32
      t.timestamps
    end
    add_index :groups, :name, :unique => true
    Group.create( :name => 'admin' )
    Group.create( :name => 'user' )
  end

  def self.down
    drop_table :groups
  end
  
end
