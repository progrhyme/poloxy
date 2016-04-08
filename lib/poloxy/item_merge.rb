# Factorial Delegator for Item Merger Class
class Poloxy::ItemMerge
  def initialize config: nil
    @config = config || Poloxy::Config.new.deliver['item']
    merger = config['merger']
    merger_s = merger.extend(CamelSnake).to_snake
    require_relative "item_merge/#{merger_s}"
    klass = Object.const_get("Poloxy::ItemMerge::#{merger}")
    @merger = klass.new
  end

  # Delegates to Item Merger Object
  def merge_into_messages list
    @merger.merge_into_messages list
  end
end
