# Factorial Delegator for Item Merger Class
class Poloxy::ItemMerge
  attr :merger

  def initialize config: nil, logger: nil, graph: nil
    @config  = config || Poloxy::Config.new
    merger   = config.deliver['item']['merger']
    merger_s = merger.extend(CamelSnake).to_snake
    require_relative "item_merge/#{merger_s}"
    klass = Object.const_get("Poloxy::ItemMerge::#{merger}")
    @merger = klass.new config: config, logger: logger, graph: graph
  end

  # Delegates to Item Merger Object
  def merge_into_messages list
    @merger.merge_into_messages list
  end
end
