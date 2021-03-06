class Poloxy::DataModel::NodeLeaf < Sequel::Model(:node_leaves)
  include Poloxy::Function::Expirable

  def self.create_or_update cond, params
    me = find cond
    if me
      me.update params
      me
    else
      props = cond.merge params
      self.dataset.insert props
      find cond
    end
  end

  # @return [Fixnum]
  #  level if not expired,
  #  {Poloxy::MIN_LEVEL} when expired
  def current_level now: Time.now
    if self.expired?
      Poloxy::MIN_LEVEL
    else
      self.level
    end
  end
end
