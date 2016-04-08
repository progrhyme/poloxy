class MForwd::Deliver::Print < MForwd::Deliver::Base
  # @param message [MForwd::DataModel::Message]
  def deliver message
    p message
  end
end
