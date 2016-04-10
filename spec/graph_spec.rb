require 'spec_helper'

describe Poloxy::Graph do
  before :context do
    @graph = Poloxy::Graph.new config: TestPoloxy.config.graph
    @root  = @graph.node
  end

  after :context do
    [:graph_nodes].each do |t|
      TestPoloxy.db[t].delete
    end
  end

  describe 'Retval of ".new" (class method)' do
    it 'is an instance' do
      expect(@graph).to be_an_instance_of Poloxy::Graph
    end

    it 'has root node' do
      expect(@root).to be_an_instance_of Poloxy::DataModel::GraphNode
      expect(@root.parent_id).to eq 0
      expect(@root.label).to eq 'root'
    end
  end

  describe "#node(group)" do
    context "Without argument" do
      it "returns @root" do
        expect(@root.parent_id).to eq 0
      end
    end

    it "Returns nil when no node exists with 'group'" do
      expect(@graph.node 'no/such/group').to be nil
    end
  end

  describe "#node!(group)" do
    before :context do
      @bar = @graph.node! 'foo/bar'
    end

    context "When no node exists in tree" do
      it "creates and returns node associated to 'group'" do
        expect(@bar).to be_an_instance_of Poloxy::DataModel::GraphNode
        expect(@bar.label).to eq 'bar'
      end

      it "creates nodes between the path through the 'group'" do
        foo = @graph.node 'foo'
        expect(foo).to be_an_instance_of Poloxy::DataModel::GraphNode
        expect(foo.label).to eq 'foo'
        expect(@bar.parent_id).to eq foo.id
      end
    end
  end
end
