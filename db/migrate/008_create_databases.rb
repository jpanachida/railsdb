class CreateDatabases < ActiveRecord::Migration
  
  def self.up
    create_table :databases do |t|
      t.integer :driver_id
      t.string  :name,        :limit => 64
      t.string  :path,        :limit => 255,  :default => nil
      t.string  :description, :limit => 255,  :default => nil
      t.string  :host,        :limit => 255,  :default => nil
      t.string  :username,    :limit => 32,   :default => nil
      t.string  :password,    :limit => 40,   :default => nil
      t.timestamps
    end
    @mysql      = Driver.find_by_name( 'mysql' )
    @oracle     = Driver.find_by_name( 'oracle' )
    @postgresql = Driver.find_by_name( 'postgresql' )
    @sqlite3    = Driver.find_by_name( 'sqlite3' )
    Database.create(  :name         => 'mysql',
                      :description  => 'This is an example MySQL database.',
                      :driver       => @mysql,
                      :host         => 'localhost',
                      :username     => 'root' )
    Database.create(  :name         => 'oracle',
                      :description  => 'This is an example Oracle/XE database.',
                      :driver       => @oracle,
                      :host         => 'localhost',
                      :username     => 'root' )
    Database.create(  :name         => 'postgresql',
                      :description  => 'This is an example PostgreSQL database.',
                      :driver       => @postgresql,
                      :host         => 'localhost',
                      :username     => 'root' )
    Database.create(  :name         => "#{ RAILS_ENV }.sqlite3",
                      :path         => "#{ RAILS_ROOT }/db/#{ RAILS_ENV }.sqlite3",
                      :description  => 'This is the main application database.',
                      :driver       => @sqlite3 )
  end

  def self.down
    drop_table :databases
  end
  
end
