require 'spec_helper'

class Poloxy::Config
  attr_accessor :deliver
end

klass      = 'PerItem'
klass_full = "Poloxy::ItemMerge::#{klass}"

describe 'Poloxy::ItemMerge::PerItem' do
  before :context do
    @config = TestPoloxy.config
    @config.deliver = { 'item' => { 'merger' => 'PerItem' } }

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
        it 'has message of each item' do
          msgs = @mc.messages
          expect(msgs.length).to eq( 2*2*2 )
          expect( msgs.map(&:item) ).to eq( @items.map(&:name) )
          expect( msgs.map(&:level) ).to eq( @items.map(&:level) )
          expect( msgs.map(&:group) ).to eq( @items.map(&:group) )
          expect( msgs.map(&:address) ).to eq( @items.map(&:address) )
        end

        it 'has no undelivered message' do
          expect(@mc.undelivered.length).to eq 0
        end
      end
    end
  end
end
