class Poloxy::Deliver::Base
  include Poloxy::Function::Loggable

  def initialize config: nil, logger: nil
    @config = config
    @logger = logger
  end

  # @param message [Poloxy::DataModel::Message]
  def deliver message
    raise Poloxy::Error, 'Please override in subclass!'
  end

  private

    def logger
      @logger
    end
end
