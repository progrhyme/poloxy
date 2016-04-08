class Poloxy::ItemMerge::Base
  def initialize
    @data_model = Poloxy::DataModel.new
  end

  # @param list [Array<Poloxy::DataModel::Item>]
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

    # @param list [Array<Poloxy::DataModel::Item>]
    def pre_merge_items list
      items = {}
      list.each do |i|
        items[i.name]          ||= {}
        items[i.name][i.level] ||= []
        items[i.name][i.level] <<  i
      end
      items
    end

    # @param name [String] Poloxy::DataModel::Item#name
    # @param stash [Hash] Poloxy::DataModel::Item#name
    #  => Hash of Array of Poloxy::DataModel::Item
    def merge_items name, stash
      raise Poloxy::Error, 'Please override in subclass!'
    end
end
