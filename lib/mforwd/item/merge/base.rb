class MForwd::Item::Merge::Base
  def initialize
  end

  def merge list
    raise MForwd::Error, 'Must be overridden in subclass!'
  end
end
