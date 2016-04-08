class Poloxy::Deliver::Print < Poloxy::Deliver::Base
  # @param message [Poloxy::DataModel::Message]
  def deliver message
    p message
  end
end
