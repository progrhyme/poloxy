class Poloxy::DataModel::NodeLeaf < Sequel::Model(:node_leaves)
  def self.create_or_update cond, params
    me = find cond
    if me
      me.update params
      nil
    else
      props = cond.merge params
      self.dataset.insert props
      find cond
    end
  end
end
