class Poloxy::MessageContainer
  include Poloxy::Function::Group

  attr :messages, :group, :level, :expire_at, :total_num, :item_num, :group_items

  def initialize config=nil, args={}
    @config      = config
    @messages    = args[:messages]  || []
    @group       = args[:group]     || nil
    @level       = args[:level]     || Poloxy::MIN_LEVEL
    @expire_at   = args[:expire_at] || Time.now
    @total_num   = args[:count]     || 0
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

  def append msg
    @messages << msg
    @group = @group ? merge_groups([ @group, msg.group ]) : msg.group
    %w[level expire_at].each do |key|
      instance_variable_set "@#{key}", [ self.send(key), msg.send(key) ].max
    end
    @total_num += 1
    @item_num  += msg.items.length
    @group_items[msg.group] ||= {}
    @group_items[msg.group][msg.item] ||= { num: 0, level: Poloxy::MIN_LEVEL }
    @group_items[msg.group][msg.item].tap do |gi|
      gi[:num]   += 1
      gi[:level]  = [ gi[:level], msg.level ].max
    end
  end

  private

    def config
      @config
    end
end
