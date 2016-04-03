# Factorial Delegator for Deliver Class
class MForwd::Deliver
  include MForwd::Util::String

  def initialize
    @deliverer = {}
  end

  # @param message [MForwd::Message]
  def deliver message
    deliverer(message.type).deliver message
  end

  private

    def deliverer type
      @deliverer[type] ||= Proc.new {
        require "mforwd/deliver/#{str_to_snake type}"
        Object.const_get("MForwd::Deliver::#{type}").new
      }.call
    end
end
