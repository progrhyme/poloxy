require 'spec_helper'

class Poloxy::Config
  attr_accessor :deliver
end

klass      = 'PerAddress'
klass_full = "Poloxy::ItemMerge::#{klass}"

describe 'Poloxy::ItemMerge::PerAddress' do
  before :context do
    @config = TestPoloxy.config
    @config.deliver = { 'item' => { 'merger' => 'PerAddress' } }

    @graph = Poloxy::Graph.new config: TestPoloxy.config
    @im    = Poloxy::ItemMerge.new config: @config, graph: @graph
    @item  = Poloxy::Item.new config: @config
    @dm    = Poloxy::DataModel.new
  end

  it "#{klass_full} is loaded" do
    expect(@im.merger).to be_an_instance_of( Object.const_get(klass_full) )
  end

  describe "#merge_into_messages called by #{klass_full}" do
    before :context do
      @items = []
      (1..2).each do |i|
        (1..2).each do |j|
          (1..2).each do |k|
            @items << @item.create({
              'name'    => "item#{i}.#{j}.#{k}",
              'level'   => k,
              'group'   => "group#{i}.#{j}",
              'type'    => 'Print',
              'address' => "addr#{i}",
              'message' => 'Alert happened!',
            })
          end
        end
      end
    end

    after :context do
      @dm.load_class('Item').dataset.delete
    end

    context 'Given prepared items' do
      before :context do
        @mc = @im.merge_into_messages @items
      end

      describe 'Merged container' do
        it 'has message of each address' do
          msgs = @mc.messages
          expect(msgs.length).to eq( 2 )
          expect( msgs.map(&:item) ).to eq( 1.upto(2).map { Poloxy::MERGED_ITEM } )
          expect( msgs.map(&:level) ).to eq( 1.upto(2).map { 2 } )
          expect( msgs.map(&:group) ).to eq( 1.upto(2).map { Poloxy::MERGED_GROUP } )
          expect( msgs.map(&:address) ).to eq( @items.map(&:address).uniq )
        end

        it 'has undelivered messages as original messages' do
          msgs = @mc.undelivered
          expect(msgs.length).to eq @items.length
          expect( msgs.map(&:item) ).to eq( @items.map(&:name) )
        end
      end
    end

    context 'When some items are snoozed' do
      before :context do
        @without_snoozed  = @items.dup
        @snoozed_messages = []
        deleted = 0
        # group (1,1) is snoozed
        # group (2,2) is not snoozed
        [ [1, 1, 1], [1, 1, 2], [2, 2, 2] ].each do |list|
          i, j, k = *list
          idx  = (i-1)*2*2 + (j-1)*2 + k-1
          item = @items[idx]
          @without_snoozed.delete_at idx - deleted
          deleted += 1
          message = @dm.spawn 'Message', {
            item:      item.name,
            group:     item.group,
            address:   item.address,
            level:     item.level,
            expire_at: Time.now + 3600,
            items:     [ item ],
          }
          @snoozed_messages << message
          @graph.update_by_message message
        end
        @mc = @im.merge_into_messages @items
      end

      after :context do
        @dm.load_class('GraphNode').dataset.delete
        @dm.load_class('NodeLeaf').dataset.delete
      end

      describe 'Merged container' do
        it 'has message of each address' do
          msgs = @mc.messages
          expect(msgs.length).to eq( 2 )
          expect( msgs.map(&:item) ).to eq( 1.upto(2).map { Poloxy::MERGED_ITEM } )
          expect( msgs.map(&:level) ).to eq( 1.upto(2).map { 2 } )
          expect( msgs.map(&:group) ).to eq( ['group1.2', Poloxy::MERGED_GROUP] )
          expect( msgs.map(&:address) ).to eq( @items.map(&:address).uniq )
        end

        it 'has snoozed messages as snoozed' do
          msgs = @mc.snoozed
          expect(msgs.length).to eq( @snoozed_messages.length )
          expect( msgs.map(&:item) ).to eq( @snoozed_messages.map(&:item) )
          expect( msgs.map(&:level) ).to eq( @snoozed_messages.map(&:level) )
          expect( msgs.map(&:group) ).to eq( @snoozed_messages.map(&:group) )
          expect( msgs.map(&:address) ).to eq( @snoozed_messages.map(&:address) )
        end
      end
    end
  end
end
