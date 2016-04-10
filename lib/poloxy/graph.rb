class Poloxy::Graph
  def initialize config: nil, logger: nil
    @config = config || Poloxy::Config.new.graph
    @logger = logger
    @data_model = Poloxy::DataModel.new
    @tree = lambda {
      nodes = @data_model.all 'GraphNode'
      if nodes.empty?
        @root = @data_model.spawn('GraphNode', label: 'Root').save
        @root.children = []
        return { @root.id => @root }
      end

      leaves = @data_model.all 'NodeLeaf'
      tree = {}
      nodes.each do |n|
        leaves.select {|l| l.node_id == n.id}.each do |l|
          n.leaves[l.item] = l
        end
        tree[n.id] = n
        tree[n.parent_id].add_child n if n.parent_id > 0
        @root = n if n.label == 'root'
      end
      tree
    }.call
  end

  # @param group [String] /path/to/group
  def node group=""
    delimiter = @config['delimiter']
    labels = group.sub(/^#{delimiter}+/, '').split(/#{delimiter}/)
    return @root if labels.empty?
    _node = @root
    labels.each do |label|
      _node = _node.child_by_label label
      return nil unless _node
    end
    _node
  end

  # @param group [String] /path/to/group
  def node! group
    _node = @root
    delimiter = @config['delimiter']
    labels = group.sub(/^#{delimiter}+/, '').split(/#{delimiter}/)
    if labels.empty?
      child = _node.child_by_label! 'default'
      @tree[child.id] ||= child
      return child
    end
    labels.each do |label|
      _node = _node.child_by_label! label
      @tree[_node.id] ||= _node
    end
    _node
  end

  # @param node [Poloxy::DataModel::GraphNode]
  def update_node_level node
    return if node.parent_id == 0
    parent  = @tree[node.parent_id]
    updater = lambda do |level|
      parent.level = level
      parent.save
      update_node_level parent
    end
    if node.level > parent.level
      updater.call node.level
    elsif node.level < parent.level
      children = parent.children.select      {|n| n.level > node.level}
      leaves   = parent.leaves.values.select {|l| l.level > node.level}
      list     = children.concat leaves
      if list.empty?
        updater.call node.level
      else
        max_level = list.map(&:level).max
        updater.call max_level if max_level < parent.level
      end
    end
  end
end
