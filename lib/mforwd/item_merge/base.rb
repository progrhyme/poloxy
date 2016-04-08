class MForwd::ItemMerge::Base
  def initialize
    @data_model = MForwd::DataModel.new
  end

  # @param list [Array<MForwd::DataModel::Item>]
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

    # @param list [Array<MForwd::DataModel::Item>]
    def pre_merge_items list
      items = {}
      list.each do |i|
        items[i.name]         ||= {}
        items[i.name][i.kind] ||= []
        items[i.name][i.kind]  << i
      end
      items
    end

    # @param name [String] MForwd::DataModel::Item#name
    # @param stash [Hash] MForwd::DataModel::Item#name
    #  => Hash of Array of MForwd::DataModel::Item
    def merge_items name, stash
      raise MForwd::Error, 'Please override in subclass!'
    end
end
