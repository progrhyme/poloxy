class Poloxy::ViewModel::Message
  include Poloxy::Function::Expirable
  [
    :id, :node_id, :address, :type, :level, :group, :item,
    :title, :body, :misc, :expire_at, :created_at, :delivered_at,
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
    '<a href="/message/%d">%d</a>' % [@id, @id]
  end

  def group_link
    '<a href="/forwards/%s">%s</a>' % [@group, @group]
  end

  def body_html
    @body.gsub(/\n/, '<br />')
  end

  def prop_for_web key
    case key
    when 'id'
      id_link
    when 'group'
      group_link
    when 'body'
      body_html
    when 'level'
      @level_text
    else
      instance_variable_get "@#{key}"
    end
  end
end
