class MForwd::Item::Merge::Base
  def initialize
    @data_model = MForwd::DataModel.new
  end

  # @param list [Array<MForwd::Item>]
  def merge_into_messages list
    return [] if list.empty?

    messages = []
    items = pre_merge_items list
    items.each_pair do |name, stash|
      messages << merge_items(name, stash)
    end
    messages
  end

  private

    # @param list [Array<MForwd::Item>]
    def pre_merge_items list
      items = {}
      list.each do |i|
        items[i.name]         ||= {}
        items[i.name][i.kind] ||= []
        items[i.name][i.kind]  << i
      end
      items
    end

    # @param name [String] MForwd::Item#name
    # @param stash [Hash] MForwd::Item#name => Hash of Array of MForwd::Item
    def merge_items name, stash
      raise MForwd::Error, 'Please override in subclass!'
    end
end
