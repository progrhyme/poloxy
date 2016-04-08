class MForwd::Graph
  def initialize config: nil, logger: nil
    @config = config || MForwd::Config.new.graph
    @logger = logger
    @data_model = MForwd::DataModel.new
    @tree = Proc.new {
      nodes = @data_model.load_class('GraphNode').all
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
      return _node.child_by_name! 'Default'
    end
    names.each do |name|
      _node = _node.child_by_name! name
    end
    _node
  end
end
