class Poloxy::DataModel::GraphNode < Sequel::Model
  attr_accessor :children, :leaves

  def label= str
    if lbl = normalize_label(str)
      super lbl
    else
      raise Poloxy::Error,
        "Invalid label specified! #{str} . Allowed pattern is '([a-z\d_-]+)'"
    end
  end

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

  def child_by_label str
    if n_lbl = normalize_label(str)
      children.find { |c| c.label == n_lbl }
    end
  end

  def child_by_label! str
    child = child_by_label str
    return child if child

    n_lbl = normalize_label str
    child = self.class.new label: n_lbl, parent_id: self.id
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

    def normalize_label str
      n_lbl = str.downcase.scan(/[\w\-\.]+/).join
      n_lbl if n_lbl.length > 0
    end
end
