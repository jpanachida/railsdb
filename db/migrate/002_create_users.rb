class CreateUsers < ActiveRecord::Migration
  
  def self.up
    create_table :users, :force => true do |t|
      t.column :username,     :string,  :null => false, :limit => 16
      t.column :email,        :string,  :null => false, :limit => 48
      t.column :passwd_hash,  :string,                  :limit => 40
      t.column :passwd_salt,  :string,                  :limit => 40
      t.column :fname,        :string,  :null => false, :limit => 32
      t.column :lname,        :string,  :null => false, :limit => 32
      t.timestamps
    end
    add_index :users, :email,     :unique => true
    add_index :users, :username,  :unique => true
    User.create(  :fname        => 'Admin',
                  :lname        => 'User',
                  :username     => 'railsdb',
                  :email        => 'user@example.com',
                  :password     => 'changeme' )
  end
  
  def self.down
    drop_table :users
  end
  
end
