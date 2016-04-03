class MForwd::Item::Merge::Base
  def initialize
  end

  # @param list [Array<MForwd::Item>]
  def merge_into_messages list
    return [] if list.empty?

    messages = []
    items = pre_merge_items list
    items.each_pair do |id, stash|
      messages << merge_items(id, stash)
    end
    messages
  end

  private

    # @param list [Array<MForwd::Item>]
    def pre_merge_items list
      items = {}
      list.each do |i|
        items[i.id]         ||= {}
        items[i.id][i.kind] ||= []
        items[i.id][i.kind]  << i
      end
      items
    end

    # @param id [String] MForwd::Item#id
    # @param stash [Hash] MForwd::Item#id => Hash of Array of MForwd::Item
    def merge_items id, stash
      raise MForwd::Error, 'Please override in subclass!'
    end
end
