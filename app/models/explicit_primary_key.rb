module ExplicitPrimaryKey
  attr_accessor :pk
  
  def before_create
    self.id = pk
  end
  
end
