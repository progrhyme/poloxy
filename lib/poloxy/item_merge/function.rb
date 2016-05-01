module Poloxy::ItemMerge::Function

  # @param data [Hash] nested Hash of {Poloxy::DataModel::Item}
  # @return [<Poloxy::MessageContainer>]
  def merge_items_template data, per: nil, config: config()
    mcontainer = Poloxy::MessageContainer.new config
    data.each_pair do |type, _data|
      _data.each_pair do |addr, tree|
        case per
        when :item
          mcontainer.merge merge_tree(tree, per: :item, config: config)
        when :group
          mcontainer.merge merge_tree(tree, per: :group, config: config)
        when :address
          _mcontainer = merge_tree(tree, per: :item, config: config)
          _mcontainer.unify
          mcontainer.merge _mcontainer
        else
          raise Poloxy::Error, "Unknown merge_items :per type! #{per}"
        end
      end
    end
    mcontainer
  end

  def merge_tree tree, per: nil, config: config()
    mcontainer = Poloxy::MessageContainer.new config
    tree.each_pair do |key, stash|
      next if key == :items
      mcontainer.merge( merge_tree(stash, per: per, config: config) )
    end
    if tree.has_key? :items
      case per
      when :item
        mcontainer.merge(
          items_to_messages(tree[:items], config: config) )
      when :group
        mcontainer.merge(
          items_to_messages(tree[:items], unify: true, config: config) )
      else
        raise Poloxy::Error, "Unknown merge_tree :per type! #{per}"
      end
    end
    mcontainer
  end

  # @param items [Hash{String => Hash}]
  def items_to_messages items, unify: false, config: config()
    mcontainer = Poloxy::MessageContainer.new config
    items.each_pair do |name, stash|
      mcontainer.append items2msg(name, stash)
    end
    mcontainer.unify if unify
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
