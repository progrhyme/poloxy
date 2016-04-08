class MForwd::Deliver::Print < MForwd::Deliver::Base
  # @param message [MForwd::Message]
  def deliver message
    p message
  end
end
