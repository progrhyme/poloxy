class MForwd::Message < Sequel::Model(:messages)
  attr_accessor :items

=begin
  @@accessors = [
    :title,   :body,  :kind,       :position,     :type,
    :address, :items, :created_at, :delivered_at, :extra,
  ]
  @@accessors.each do |accr|
    attr accr
  end

  def initialize params
    params.each_pair do |key, val|
      instance_variable_set("@#{key}", val)
    end
  end
=end

end
