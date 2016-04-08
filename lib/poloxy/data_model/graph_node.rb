class Poloxy::DataModel::GraphNode < Sequel::Model
  attr_accessor :children

  def save
    self.updated_at = Time.now
    super
  end

  def children
    @children ||= []
  end

  def add_child node
    self.children << node
  end

  def child_by_name! name
    child = children.find { |c| c.name == name }
    return child if child

    child = self.class.new name: name, parent_id: self.id
    child.save

    self.add_child child
    child
  end
end
