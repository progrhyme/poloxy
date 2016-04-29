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
    before :context do
      @node = @graph.node! 'default'
    end

    {
      ''         => '/',
      'default'  => '/default',
      '/default' => '/default',
      'default/' => '/default',
    }.each_pair do |str, group|
      it "given '#{str}' - Node#group => '#{group}'" do
        expect(@graph.node(str).group).to eq group
      end
    end

    it "Returns nil when no node exists with 'group'" do
      %w[no/such/group root /root].each do |str|
        expect(@graph.node str).to be nil
      end
    end
  end

  describe "#node!(group)" do
    before :context do
      @bar = @graph.node! 'foo/bar'
    end

    {
      'foo'          => '/foo',
      'foo/bar'      => '/foo/bar',
      '/foo/bar'     => '/foo/bar',
      '/foo/bar/'    => '/foo/bar',
      ' /f oo/bar/ ' => '/foo/bar',
      ''             => '/default',
      '/'            => '/default',
      '//'           => '/default',
      'root'         => '/root',
      '/root'        => '/root',
    }.each_pair do |str, group|
      it "given '#{str}' - Node#group => '#{group}'" do
        expect(@graph.node!(str).group).to eq group
      end
    end

    %w[+ &* q//+/ /q/}{/].each do |group|
      it "#{group} is invalid group" do
        expect(@graph.node group).to be nil
        expect { @graph.node! group }.to raise_error Poloxy::Error
      end
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

  describe "#update_node(node)" do
    before :context do
      @graph.node!('a/b').expire_at = Time.now + 3600 # should not expire
      @graph.node!('d/e').expire_at = Time.now + 3600
    end

    context "When node.level grows" do
      it "root.level also grows" do
        a = @graph.node 'a'
        a.level = 3
        a.expire_at = Time.now + 3600
        @graph.update_node a
        expect(@root.level).to eq 3
      end
    end

    context "When level of child gets higher" do
      before :context do
        @d = @graph.node 'd'
        @e = @graph.node 'd/e'
        @e.level = 2
        @graph.update_node @e
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
        @graph.update_node @e
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
          @c.expire_at = Time.now + 3600
          @b.level = 1
          @graph.update_node @b
        end

        it "parent's level doesn't go below other children" do
          expect(@a.level).to eq 2
        end

        it "parent's level doesn't go below its leaves" do
          msg = Poloxy::DataModel.new.spawn 'Message', {
            item:      'AAA',
            level:     2,
            expire_at: Time.now + 3600, # should not expire
          }
          @a.update_leaf msg
          @c.level = 1
          @graph.update_node @c
          expect(@a.level).to eq 2
        end
      end
    end
  end
end
