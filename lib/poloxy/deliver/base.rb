class Poloxy::Deliver::Base

  def initialize config: nil, logger: nil
    @config = config
    @logger = logger
  end

  # @param message [Poloxy::DataModel::Message]
  def deliver message
    raise Poloxy::Error, 'Please override in subclass!'
  end

  private

    def write_log msg=nil, level=:info
      return unless @logger
      @logger.send(level, msg)
    end
end
