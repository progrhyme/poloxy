require 'spec_helper'

describe Poloxy::Graph do
  before :context do
    @graph = Poloxy::Graph.new config: TestPoloxy.config.graph
    @root  = @graph.node
  end
  describe 'Retval of ".new" (class method)' do
    it 'is an instance' do
      expect(@graph).to be_an_instance_of Poloxy::Graph
    end

    it 'has root node' do
      expect(@root).to be_an_instance_of Poloxy::DataModel::GraphNode
      expect(@root.id).to eq 1
      expect(@root.parent_id).to eq 0
      expect(@root.label).to eq 'root'
    end
  end
end
