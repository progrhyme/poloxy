class MForwd::Deliver::Base
  def initialize
  end

  # @param message [MForwd::Message]
  def deliver message
    raise MForwd::Error, 'Please override in subclass!'
  end
end
