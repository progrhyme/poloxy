class Poloxy::ViewModel::Item
  include Poloxy::Function::Expirable
  [
    :id, :message_id, :address, :type, :level, :group, :name,
    :message, :misc, :expire_at, :received_at,
  ].each do |accr|
    attr accr
  end
  attr_accessor :level_text, :style

  def initialize params
    params.each_pair do |key, val|
      instance_variable_set "@#{key}", val
    end
  end

  def self.from_data data
    stash = {}
    data.columns.each do |col|
      stash[col] = data.send col
    end
    new stash
  end

  def id_link
    '<a href="/item/%d">%d</a>' % [@id, @id]
  end

  def message_id_link
    '<a href="/message/%d">%d</a>' % [@message_id, @message_id]
  end

  def group_link
    '<a href="/inwards/%s">%s</a>' % [@group, @group]
  end

  def message_html
    message.gsub(/\n/, '<br />')
  end

  def prop_for_web key
    case key
    when 'id'
      id_link
    when 'message_id'
      message_id_link
    when 'group'
      group_link
    when 'message'
      message_html
    when 'level'
      @level_text
    else
      instance_variable_get "@#{key}"
    end
  end
end
