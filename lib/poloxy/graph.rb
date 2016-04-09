class Poloxy::Graph
  def initialize config: nil, logger: nil
    @config = config || Poloxy::Config.new.graph
    @logger = logger
    @data_model = Poloxy::DataModel.new
    @tree = Proc.new {
      nodes = @data_model.all 'GraphNode'
      if nodes.empty?
        @root = @data_model.spawn('GraphNode', name: 'Root').save
        @root.children = []
        return { @root.id => @root }
      end

      tree = {}
      nodes.each do |n|
        tree[n.id] = n
        tree[n.parent_id].add_child n if n.parent_id > 0
        @root = n if n.name == 'Root'
      end
      tree
    }.call
  end

  # @param group [String] /path/to/group
  def node group
    _node = @root
    delimiter = @config['delimiter']
    names = group.sub(/^#{delimiter}+/, '').split(/#{delimiter}/)
    if names.empty?
      child = _node.child_by_name! 'Default'
      @tree[child.id] ||= child
      return child
    end
    names.each do |name|
      _node = _node.child_by_name! name
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
      children = parent.children.select {|n| n.level > node.level}
      if children.empty?
        updater.call node.level
      else
        max_level = children.map(&:level).max
        updater.call max_level if max_level < parent.level
      end
    end
  end
end
