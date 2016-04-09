class Poloxy::DataModel::GraphNode < Sequel::Model
  attr_accessor :children, :leaves

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

  def child_by_name name
    children.find { |c| c.name == name }
  end

  def child_by_name! name
    child = child_by_name name
    return child if child

    child = self.class.new name: name, parent_id: self.id
    child.leaves = []
    child.save

    self.add_child child
    child
  end

  # @param level [Fixnum] messages.level
  # @param item [String] messages.item
  def update_level_by_item level, item
    leaf_dm = data_model().load_class 'NodeLeaf'
    leaf_dm.create_or_update(
      { node_id: self.id, item:       item     },
      { level:   level,   updated_at: Time.now },
    ).tap do |leaf|
      self.leaves << leaf if leaf
    end
    updated_level = 0
    if level > self.level
      self.level = updated_level = level
    elsif level < self.level
      leaves = leaf_dm.where(
        'node_id = ? AND item <> ? AND level > ?',
        self.id, item, level
      )
      if leaves.empty?
        self.level = updated_level = level
      else
        max_level = leaves.map(&:level).max
        if max_level < self.level
          self.level = updated_level = max_level
        end
      end
    end
    save
    updated_level
  end

  private

    def data_model
      @data_model ||= Poloxy::DataModel.new
    end
end
