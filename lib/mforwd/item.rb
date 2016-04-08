class MForwd::Item
  @@accessors = [:name, :kind, :position, :type, :address, :message, :created_at, :extra]
  @@accessors.each do |accr|
    attr accr
  end

  def initialize params
    params.each_pair do |key, val|
      instance_variable_set("@#{key}", val)
    end
    @created_at ||= Time.now.to_i
  end

  def encode
    stash = {}
    @@accessors.each do |accr|
      stash[accr] = instance_variable_get("@#{accr}")
    end
    stash
  end

  def self.decode data
    item = new JSON.parse(data)
  end
end
