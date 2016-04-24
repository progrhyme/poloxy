class Poloxy::ItemMerge::Base
  def initialize config: nil
    @config     = config || Poloxy::Config.new
    @data_model = Poloxy::DataModel.new
  end

  # @param list [Array<Poloxy::DataModel::Item>]
  # @return [Array<Poloxy::DataModel::Message>]
  def merge_into_messages list
    return [] if list.empty?

    messages = []
    items = pre_merge_items list
    merge_items(items)
  end

  private

    def config
      @config
    end

    # @param list [Array<Poloxy::DataModel::Item>]
    def pre_merge_items list
      items = {}
      list.each do |i|
        groups = i.group.split(@config.graph['delimiter'])
        items[i.type]            ||= {}
        items[i.type][i.address] ||= {}
        bucket = items[i.type][i.address]
        groups.each do |grp|
          bucket = bucket[grp] ||= {}
        end
        bucket[:items]                  ||= {}
        bucket[:items][i.name]          ||= {}
        bucket[:items][i.name][i.level] ||= []
        bucket[:items][i.name][i.level] <<  i
      end
      items
    end

    def merge_items items
      raise Poloxy::Error, 'Please override in subclass!'
    end
end
