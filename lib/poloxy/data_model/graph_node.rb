class Poloxy::DataModel::GraphNode < Sequel::Model
  include Poloxy::Function::Expirable
  attr_accessor :children, :leaves, :group

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

  def save
    self.updated_at   = Time.now
    self.expire_at  ||= Time.now
    super
  end

  def children
    @children ||= []
  end

  def leaves
    @leaves ||= {}
  end

  def valid_children
    children.select { |c| ! c.expired? }
  end

  def valid_leaves
    leaves.select { |name, leaf| ! leaf.expired? }
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
  def child_by_label! str, delim='/'
    child = child_by_label str
    return child if child

    n_lbl = normalize_label str
    return nil unless n_lbl
    child = self.class.new label: n_lbl, parent_id: self.id
    child.group = [self.group, n_lbl].join(delim).gsub(/#{delim}+/, "#{delim}")
    child.save

    self.add_child child
    child
  end

  # @param message [Poloxy::DataModel::Message]
  def update_leaf message
    item    = message.item
    level   = message.level
    expire  = message.expire_at
    leaf_dm = data_model().load_class 'NodeLeaf'
    leaf_dm.create_or_update(
      { node_id: self.id, item: item },
      { level: level, updated_at: Time.now, expire_at: expire },
    ).tap do |leaf|
      self.leaves[item] = leaf
    end
    if level > self.level
      self.level = level
    elsif level < self.level
      children = self.valid_children.select      {|n| n.level > level}
      leaves   = self.valid_leaves.values.select {|l| l.level > level}
      list     = children.concat leaves
      if list.empty?
        self.level = level
      else
        max_level = list.map(&:level).max
        if max_level < self.level
          self.level = max_level
        end
      end
    end
    self.expire_at = [ self.expire_at, expire ].max
    save
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
