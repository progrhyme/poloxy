class MForwd::Deliver::HttpPost < MForwd::Deliver::Base

  # @param message [MForwd::Message]
  def deliver message
    p "Sent #{message}"
  end
end
