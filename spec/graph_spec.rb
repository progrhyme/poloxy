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

  describe "#update_node_level" do
    before :context do
      @graph.node! 'a/b'
      @graph.node! 'd/e'
    end

    context "When node.level grows" do
      it "root.level also grows" do
        a = @graph.node 'a'
        a.level = 3
        @graph.update_node_level a
        expect(@root.level).to eq 3
      end
    end

    context "When level of child gets higher" do
      before :context do
        @d = @graph.node 'd'
        @e = @graph.node 'd/e'
        @e.level = 2
        @graph.update_node_level @e
      end

      it "level of parent also grows" do
        expect(@d.level).to eq 2
      end

      context "When parent's level is higher" do
        it "level of parent doesn't change" do
          expect(@root.level).to eq 3
        end
      end
    end

    context "When level of child goes lower" do
      before :context do
        @d = @graph.node 'd'
        @e = @graph.node 'd/e'
        @e.level = 1
        @graph.update_node_level @e
      end
      it "level of parent with no other child or no leaf also goes lower" do
        expect(@d.level).to eq 1
      end

      it "level of parent with another child with higher level doesn't change" do
        expect(@root.level).to eq 3
      end

      context "When parent's level goes down" do
        before :context do
          @a = @graph.node 'a'
          @b = @graph.node 'a/b'
          @c = @graph.node! 'a/c'
          @c.level = 2
          @b.level = 1
          @graph.update_node_level @b
        end

        it "parent's level doesn't go below other children" do
          expect(@a.level).to eq 2
        end

        it "parent's level doesn't go below its leaves" do
          @a.update_leaf item: 'AAA', level: 2
          @c.level = 1
          @graph.update_node_level @c
          expect(@a.level).to eq 2
        end
      end
    end
  end
end
