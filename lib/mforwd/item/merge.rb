# Factorial Delegator for Item Merger Class
class MForwd::Item::Merge
  def initialize config: nil
    @config = config || MForwd::Config.new.deliver['item']
    merger = config['merger']
    merger_s = merger.extend(CamelSnake).to_snake
    require_relative "merge/#{merger_s}"
    klass = Object.const_get("MForwd::Item::Merge::#{merger}")
    @merger = klass.new
  end

  # Delegates to Item Merger Object
  def merge_into_messages list
    @merger.merge_into_messages list
  end
end
