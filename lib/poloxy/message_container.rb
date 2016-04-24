class Poloxy::MessageContainer
  attr :messages, :level, :total_num, :item_num
  def initialize config=nil, args={}
    @messages  = args[:messages] || []
    @level     = args[:level]    || Poloxy::MIN_LEVEL
    @total_num = args[:count]    || 0
    @item_num  = args[:item_num] || 0
  end

  def merge other
    @messages.concat other.messages
    @level     =  [@level, other.level].max
    @total_num += other.total_num
    @item_num  += other.item_num
  end

  def append msg
    @messages << msg
  end
end
