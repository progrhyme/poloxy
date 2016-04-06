class MForwd::Deliver::Slack < MForwd::Deliver::HttpPost

  private

  # @param message [MForwd::Message]
  def create_body message
    { text: message.body }.to_json
  end
end
