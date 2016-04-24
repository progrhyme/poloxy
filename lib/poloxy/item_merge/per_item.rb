class Poloxy::ItemMerge::PerItem < Poloxy::ItemMerge::Base
  include Poloxy::ViewHelper

  private

  # @param data [Hash] nested Hash of {Poloxy::DataModel::Item}
  def merge_items data
    messages = []
    data.each_pair do |type, _data|
      _data.each_pair do |addr, tree|
        mcontainer = merge_tree(tree)
        messages.concat(mcontainer.messages)
      end
    end
    messages
  end

  # @param tree [Hash] nested Hash of {Poloxy::DataModel::Item}
  def merge_tree tree
    mcontainer = Poloxy::MessageContainer.new @config
    tree.each_pair do |key, stash|
      next if key == :items
      mcontainer.merge( merge_tree(stash) )
    end
    if tree.has_key? :items
      mcontainer.merge( items_to_messages(tree[:items]) )
    end
    mcontainer
  end

  # @param items [Hash{String => Hash}]
  def items_to_messages items
    mcontainer = Poloxy::MessageContainer.new @config
    items.each_pair do |name, stash|
      mcontainer.append items2msg(name, stash)
    end
    mcontainer
  end

  # @param name [String] {Poloxy::DataModel::Item#name}
  # @param items [Hash{String => Array<Poloxy::DataModel::Item>}]
  #  key: {Poloxy::DataModel::Item#level}
  def items2msg name, items
    params = {
      'item'  => name,
      'items' => [],
    }

    items.first[1].first.tap do |item|
      %w[group type address].each do |key|
        params[key] = item.send(key)
      end
    end

    lv2label = lambda do |lv|
      abbrev, _lv = abbrev_and_level lv
      if lv == _lv
        abbrev
      else
        "%s(Lv%d)" % [abbrev, lv]
      end
    end

    levels   = items.keys
    worst_lv = levels.max
    worst_label = lv2label.call worst_lv
    params['level'] = worst_lv
    params['title'] = '%s / %s' % [worst_label, name]

    if levels.size == 1
      list = params['items'] = items.first[1]
      params['body']  = <<EOB
# #{list.length} items.
# Latest message:
#{list.last.message}
EOB
    else
      nums  = {}
      total = 0
      levels.sort.reverse.each do |lv|
        label       =  lv2label.call lv
        list        =  items[lv]
        nums[label] =  list.length
        total       += list.length
        params['items'].concat(list)
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
