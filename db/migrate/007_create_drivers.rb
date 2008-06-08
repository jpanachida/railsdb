class CreateDrivers < ActiveRecord::Migration
  
  def self.up
    create_table :drivers do |t|
      t.string :name, :limit => 64
      t.timestamps
    end
    %w( mysql oracle postgresql sqlite3 ).sort.each do |d|
      Driver.create( :name => d )
    end
  end

  def self.down
    drop_table :drivers
  end
  
end
