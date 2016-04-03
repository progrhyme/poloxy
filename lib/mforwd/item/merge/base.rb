class MForwd::Item::Merge::Base
  def initialize
  end

  def merge list
    p '%s %s' % [self.class, list]
  end
end
