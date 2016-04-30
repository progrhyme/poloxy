class Poloxy::MessageContainer
  include Poloxy::Function::Group
  include Poloxy::ViewHelper

  attr :messages, :group, :level, :expire_at, :total_num, :kind_num, :item_num, :group_items

  def initialize config=nil, args={}
    @config      = config
    @messages    = args[:messages]  || []
    @group       = args[:group]     || nil
    @level       = args[:level]     || Poloxy::MIN_LEVEL
    @expire_at   = args[:expire_at] || Time.now
    @total_num   = args[:count]     || 0
    @kind_num    = args[:count]     || 0
    @item_num    = args[:item_num]  || 0
    @group_items = {}
    @data_model  = Poloxy::DataModel.new
  end

  def merge other
    @messages.concat other.messages
    @group = @group ? merge_groups([ @group, other.group ]) : other.group
    %w[level expire_at].each do |key|
      instance_variable_set "@#{key}", [ self.send(key), other.send(key) ].max
    end
    @total_num += other.total_num
    @kind_num  += other.kind_num
    @item_num  += other.item_num
    other.group_items.each_pair do |group, stash|
      @group_items[group] ||= {}
      stash.each_pair do |item, data|
        @group_items[group][item] ||= { num: 0, level: Poloxy::MIN_LEVEL }
        @group_items[group][item].tap do |gi|
          gi[:num]   += data[:num]
          gi[:level]  = [ gi[:level], data[:level] ].max
        end
      end
    end
  end

  # @note Suppose msg.group or msg.item is different from @messages contents
  def append msg
    @messages << msg
    @group = @group ? merge_groups([ @group, msg.group ]) : msg.group
    %w[level expire_at].each do |key|
      instance_variable_set "@#{key}", [ self.send(key), msg.send(key) ].max
    end
    @total_num += 1
    @kind_num  += 1
    @item_num  += msg.items.length
    @group_items[msg.group] ||= {}
    @group_items[msg.group][msg.item] ||= { num: 0, level: Poloxy::MIN_LEVEL }
    @group_items[msg.group][msg.item].tap do |gi|
      gi[:num]   += 1
      gi[:level]  = [ gi[:level], msg.level ].max
    end
  end

  # @note Diffrence of addresses and types of messages are ignored.
  def unify
    return if @messages.length == 1

    params = {
      'group'       => @group,
      'item'        => Poloxy::MERGED_ITEM,
      'items'       => [],
      'level'       => @level,
      'expire_at'   => @expire_at,
    }
    @messages.first.tap do |m|
      %w[type address].each do |key|
        params[key] = m.send(key)
      end
    end

    @messages.each do |m|
      params['items'].concat m.items
    end

    params['title'] = '%s (%s) %d Alerts via POLOXY' % [
      abbrev_with_level(params['level']), params['group'], @item_num ]

    params['body'] = ERB.new(<<EOB, nil, '-').result(binding)
There are <%= @item_num %> items of <%= @kind_num %> kinds of <%= @group_items.size %> groups.

<%- @group_items.each_pair do |group, stash| -%>
[<%= group %>]
  <%- stash.each_pair do |item, data| -%>
- <%= item %> : <%= data[:num] %> items, worst = <%= abbrev_with_level(data[:level]) %>
  <%- end -%>
<%- end -%>
EOB

    params['created_at'] = Time.now
    message = @data_model.spawn 'Message', params

    # TODO:
    #  Update with lost messages

    @messages  = [ message ]
    @group     = message.group
    @level     = message.level
    @total_num = 1
    @group_items = {
      @group => {
        message.item => { num: @item_num, level: @level },
      },
    }
  end

  private

    def config
      @config
    end
end
