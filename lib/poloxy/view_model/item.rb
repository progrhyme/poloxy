class Poloxy::ViewModel::Item
  [
    :id, :message_id, :address, :type, :level, :group, :name,
    :message, :misc, :received_at,
  ].each do |accr|
    attr accr
  end
  attr_accessor :level_text

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

  def message_html
    message.gsub(/\n/, '<br />')
  end

  def prop_for_web key
    case key
    when 'message'
      message_html
    when 'level'
      @level_text
    else
      instance_variable_get "@#{key}"
    end
  end
end
