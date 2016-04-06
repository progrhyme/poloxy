class MForwd::Message
  @@accessors = [:title, :body, :kind, :position, :type, :address, :delivered_at, :extra]
  @@accessors.each do |accr|
    attr accr
  end

  def initialize params
    params.each_pair do |key, val|
      instance_variable_set("@#{key}", val)
    end
  end

end
