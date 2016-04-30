class Poloxy::ItemMerge::Base
  include Poloxy::ViewHelper

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

  # @param name [String] {Poloxy::DataModel::Item#name}
  # @param items [Hash{String => Array<Poloxy::DataModel::Item>}]
  #  key: {Poloxy::DataModel::Item#level}
  def items2msg name, items
    params = {
      'item'        => name,
      'items'       => [],
    }

    items.first[1].first.tap do |item|
      %w[group type address].each do |key|
        params[key] = item.send(key)
      end
    end

    levels   = items.keys
    worst_lv = levels.max
    worst_label = abbrev_with_level worst_lv
    params['level'] = worst_lv
    params['title'] = '%s / %s' % [worst_label, name]

    if levels.size == 1
      list = params['items'] = items.first[1]
      params['expire_at'] = list.map(&:expire_at).max
      params['body']  = <<EOB
# #{list.length} items.
# Latest message:
#{list.last.message}
EOB
    else
      nums  = {}
      total = 0
      params['expire_at'] = Time.now
      levels.sort.reverse.each do |lv|
        label       =  abbrev_with_level lv
        list        =  items[lv]
        nums[label] =  list.length
        total       += list.length
        params['items'].concat(list)
        params['expire_at'] = list.map(&:expire_at).push( params['expire_at'] ).max
      end
      params['body'] = ERB.new(<<EOB, nil, '-').result(binding)
# There are <%= total %> items of <%= nums.size %> levels:
<% nums.each do |label, num| -%>
#   <%= "%-7s" % [label] %> => <%= num %>
<% end -%>
# ----
# Latest message at `<%= worst_label %>`:
<%= items[worst_lv].last.message %>
EOB
    end

    params['created_at'] = Time.now
    @data_model.spawn 'Message', params
  end
end
