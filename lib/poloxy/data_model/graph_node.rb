class Poloxy::DataModel::GraphNode < Sequel::Model
  attr_accessor :children, :leaves

  # Override to normalize given label string
  # @param str [String] any string; pre-normalized label
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

  def leaves
    @leaves ||= {}
  end

  # Add to \@children
  # @param node [Poloxy::DataModel::GraphNode]
  def add_child node
    self.children << node
  end

  # @param str [String] any string; pre-normalized label
  def child_by_label str
    if n_lbl = normalize_label(str)
      children.find { |c| c.label == n_lbl }
    end
  end

  # @param str [String] any string; pre-normalized label
  def child_by_label! str
    child = child_by_label str
    return child if child

    n_lbl = normalize_label str
    child = self.class.new label: n_lbl, parent_id: self.id
    child.save

    self.add_child child
    child
  end

  # @param item [String] messages.item
  # @param level [Fixnum] messages.level
  def update_leaf item: nil, level: nil
    leaf_dm = data_model().load_class 'NodeLeaf'
    leaf_dm.create_or_update(
      { node_id: self.id, item:       item     },
      { level:   level,   updated_at: Time.now },
    ).tap do |leaf|
      self.leaves[item] = leaf
    end
    updated_level = 0
    if level > self.level
      self.level = updated_level = level
    elsif level < self.level
      children = self.children.select      {|n| n.level > level}
      leaves   = self.leaves.values.select {|l| l.level > level}
      list     = children.concat leaves
      if list.empty?
        self.level = updated_level = level
      else
        max_level = list.map(&:level).max
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

    # @param str [String] any string; pre-normalized label
    def normalize_label str
      n_lbl = str.downcase.scan(/[\w\-\.]+/).join
      n_lbl if n_lbl.length > 0
    end
end
