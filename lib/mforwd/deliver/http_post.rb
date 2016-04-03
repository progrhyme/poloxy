class MForwd::Deliver::HttpPost
  def initialize
  end

  # @param message [MForwd::Message]
  def deliver message
    p "Sent #{message}"
  end
end
