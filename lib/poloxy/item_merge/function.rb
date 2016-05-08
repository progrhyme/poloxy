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

  # @param items [Hash{String => Array}]
  def items_to_messages items, unify: false, config: config()
    mcontainer = Poloxy::MessageContainer.new config
    items.each_pair do |name, list|
      mcontainer.append items2msg(name, list)
    end
    mcontainer.unify if unify
    mcontainer
  end

  # @param name [String] {Poloxy::DataModel::Item#name}
  # @param items [Array<Poloxy::DataModel::Item>}]
  def items2msg name, items
    params = {
      'item'  => name,
      'items' => items,
    }

    leaf = @graph.leaf_by_item(items.last)

    items.last.tap do |item|
      %w[group type address level expire_at misc].each do |key|
        params[key] = item.send(key)
      end
    end

    lv_label = abbrev_with_level params['level']
    params['title'] = '%s / %s' % [lv_label, name]

    nums = {}
    items.each do |i|
      label = abbrev_with_level i.level
      nums[label] = nums[label] ? nums[label] + 1 : 1
    end

    now = Time.now
    if nums.size == 1
      if leaf && leaf.level == params['level'] && leaf.snooze_to > now
        params['is_snoozed'] = true
      end
      params['body'] = <<EOB
# #{items.length} items.
# Latest message:
#{items.last.message}
EOB
    else
      params['body'] = ERB.new(<<EOB, nil, '-').result(binding)
# There are <%= items.length %> items of <%= nums.size %> levels:
<% nums.each_pair do |label, num| -%>
#   <%= "%-7s" % [label] %> => <%= num %>
<% end -%>
# ----
# Latest message at `<%= lv_label %>`:
<%= items.last.message %>
EOB
    end

    params['created_at'] = now
    @data_model.spawn 'Message', params
  end
end
