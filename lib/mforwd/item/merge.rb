# Factorial Delegator for Item Merger Class
class MForwd::Item::Merge
  def initialize config: nil
    @config = config || MForwd::Config.new.deliver['item']
    merger = config['merger']
    require "mforwd/item/merge/#{merger.downcase}"
    klass = Object.const_get("MForwd::Item::Merge::#{merger.capitalize}")
    @merger = klass.new
  end

  # Delegates to Item Merger Object
  def merge_into_messages list
    @merger.merge_into_messages list
  end
end
