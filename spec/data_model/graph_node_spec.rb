require 'spec_helper'

klass = 'Poloxy::DataModel::GraphNode'
describe klass do
  before :context do
    @dm    = Poloxy::DataModel.new
    @klass = @dm.load_class 'GraphNode'
    @graph = Poloxy::Graph.new config: TestPoloxy.config.graph
    @root  = @graph.node
  end

  after :context do
    [:graph_nodes, :node_leaves].each do |t|
      TestPoloxy.db[t].delete
    end
  end

  describe '#child_by_label!(label)' do
    before :context do
      @child  = @root.child_by_label! 'Default'
      @child2 = @root.child_by_label! 'Default'
    end
    context "When it doesn't have child with the label" do
      it "child is a #{klass}" do
        expect(@child).to be_an_instance_of @klass
      end
      it "child has the label" do
        expect(@child.label).to eq 'default'
      end
      it "child.parent_id is parent.id" do
        expect(@child.parent_id).to eq @root.id
      end
    end
    context 'When it has child with the label' do
      it "returns the same node" do
        expect(@child2).to be @child
      end
    end
  end

  describe "#update_leaf(item, level)" do
    before :context do
      @node = @graph.node 'default'
      @node.update_leaf item: 'Foo', level: 2
    end

    context "When it has no leaf" do
      it "node.level is updated by given level" do
        expect(@node.level).to eq 2
      end
    end

    context "When it has another leaf" do
      context "When given level is lower" do
        it "node.level is not updated" do
          @node.update_leaf item: 'Bar', level: 1
          expect(@node.level).to eq 2
        end
      end
      context "When given level is higher" do
        it "node.level is updated" do
          @node.update_leaf item: 'Bar', level: 3
          expect(@node.level).to eq 3
        end
      end
      context "When leaf with higher level goes lower" do
        it "node.level is capped by another leaf.level" do
          @node.update_leaf item: 'Bar', level: 1
          expect(@node.level).to eq 2
        end
      end
    end

    context "When it has other leaves and children" do
      before :context do
        @child = @graph.node! 'default/sub'
        @child.update_leaf item: 'foo', level: 2
      end

      context "When leaf with higher level goes lower" do
        it "node.level is capped by max level of leaves and children" do
          @node.update_leaf item: 'Foo', level: 1
          expect(@node.level).to eq 2
        end
      end
    end
  end

  describe '#normalize_label' do
    {
      ''             => nil,
      '/ / &%$'      => nil,
      'Foo'          => 'foo',
      ' F oO123 '    => 'foo123',
      '/path/to/dir' => 'pathtodir',
      'Bar.baz-1_2'  => 'bar.baz-1_2',
    }.each do |str, label|
      it "'#{str}' => #{label.inspect}" do
        expect(@klass.new.send(:normalize_label, str)).to eq label
      end
    end

  end
end
