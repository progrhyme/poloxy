# Factorial Delegator for Deliver Class
class Poloxy::Deliver
  def initialize config: nil, logger: nil
    @config    = config
    @logger    = logger
    @deliverer = {}
  end

  # @param message [Poloxy::Message]
  def deliver message
    deliverer(message.type).deliver message
  end

  private

    # @param type [String] deliverer type
    def deliverer type
      type_s = type.extend(CamelSnake).to_snake
      @deliverer[type] ||= Proc.new {
        require_relative "deliver/#{type_s}"
        Object.const_get("Poloxy::Deliver::#{type}").new config: @config, logger: @logger
      }.call
    end
end
