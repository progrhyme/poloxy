# Factorial Delegator for Deliver Class
class MForwd::Deliver
  def initialize logger: nil
    @logger    = logger
    @deliverer = {}
  end

  # @param message [MForwd::Message]
  def deliver message
    deliverer(message.type).deliver message
  end

  private

    # @param type [String] deliverer type
    def deliverer type
      type_s = type.extend(CamelSnake).to_snake
      @deliverer[type] ||= Proc.new {
        require "mforwd/deliver/#{type_s}"
        Object.const_get("MForwd::Deliver::#{type}").new logger: @logger
      }.call
    end
end
