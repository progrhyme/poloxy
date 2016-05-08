class Poloxy::ItemMerge::Base
  include Poloxy::Function::Loggable
  include Poloxy::ViewHelper

  def initialize config: nil, logger: nil, graph: nil
    @config     = config || Poloxy::Config.new
    @logger     = logger
    @graph      = graph
    @data_model = Poloxy::DataModel.new
  end

  # @param list [Array<Poloxy::DataModel::Item>]
  # @return [<Poloxy::MessageContainer>]
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

  def logger
    @logger
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
      bucket[:items]         ||= {}
      bucket[:items][i.name] ||= []
      bucket[:items][i.name]  << i
    end
    items
  end

  # @param data [Hash] nested Hash of {Poloxy::DataModel::Item}
  # @return [<Poloxy::MessageContainer>]
  def merge_items data
    raise Poloxy::Error, 'Please override in subclass!'
  end
end
