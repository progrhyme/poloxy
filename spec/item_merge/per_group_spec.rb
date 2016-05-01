require 'spec_helper'

class Poloxy::Config
  attr_accessor :deliver
end

klass      = 'PerGroup'
klass_full = "Poloxy::ItemMerge::#{klass}"

describe 'Poloxy::ItemMerge::PerGroup' do
  before :context do
    @config = TestPoloxy.config
    @config.deliver = { 'item' => { 'merger' => 'PerGroup' } }

    @im   = Poloxy::ItemMerge.new config: @config
    @item = Poloxy::Item.new config: @config
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
      Poloxy::DataModel.new.load_class('Item').dataset.delete
    end

    context 'Given prepared items' do
      before :context do
        @mc = @im.merge_into_messages @items
      end

      describe 'Merged container' do
        it 'has message of each group' do
          msgs = @mc.messages
          expect(msgs.length).to eq( 2*2 )
          expect( msgs.map(&:item) ).to eq( 1.upto(2*2).map { Poloxy::MERGED_ITEM } )
          expect( msgs.map(&:level) ).to eq( 1.upto(2*2).map { 2 } )
          expect( msgs.map(&:group) ).to eq( @items.map(&:group).uniq )
        end

        it 'has undelivered messages as original messages' do
          msgs = @mc.undelivered
          expect(msgs.length).to eq @items.length
          expect( msgs.map(&:item) ).to eq( @items.map(&:name) )
        end
      end
    end
  end
end
