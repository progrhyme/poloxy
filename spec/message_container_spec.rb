require 'spec_helper'

describe Poloxy::MessageContainer do
  before :context do
    @mc = Poloxy::MessageContainer.new TestPoloxy.config
    @dm = Poloxy::DataModel.new
    @itm = ->(n, g, lv){
      @dm.spawn 'Item', { name: n, group: g, level: lv }
    }
    @msg = ->(items){
      @dm.spawn 'Message', {
        item:  items.first.name,
        group: items.first.group,
        level: items.map(&:level).max,
        expire_at: Time.now + 3600,
        items: items,
      }
    }
  end

  describe '#append' do
    before :context do
      i  = @itm.call('foo', 'default', 3)
      @m = @msg.call([ i ])
      @mc.append @m
    end

    context '1st append' do
      it 'params of message are merged' do
        %w[group level expire_at].each do |key|
          expect( @mc.send(key) ).to eq @m.send(key)
        end
        expect(@mc.total_num).to eq 1
        expect(@mc.item_num).to eq 1
        expect(@mc.group_items).to eq({
          @m.group => {
            @m.item => { num: 1, level: @m.level },
          },
        })
      end
    end

    context '2nd append' do
      before :context do
        i   = @itm.call('bar', 'generic', 4)
        @m2 = @msg.call([ i ])
        @mc.append @m2
      end

      it 'params of message are merged' do
        expect(@mc.group).to eq Poloxy::MERGED_GROUP
        %w[level expire_at].each do |key|
          expect( @mc.send(key) ).to eq @m2.send(key)
        end
        expect(@mc.total_num).to eq 2
        expect(@mc.item_num).to eq 2
        expect(@mc.group_items).to eq({
          @m.group => {
            @m.item => { num: 1, level: @m.level },
          },
          @m2.group => {
            @m2.item => { num: 1, level: @m2.level },
          },
        })
      end
    end
  end

  describe '#merge' do
    before :context do
      @mcs = (1..3).map do |i|
        mc  = Poloxy::MessageContainer.new(TestPoloxy.config)
        itm = @itm.call("item#{i}", "group#{i}", i + 1)
        mc.append( @msg.call([ itm ]) )
        mc
      end
      @mcs[0].merge @mcs[1]
    end

    context '1st merge' do
      it 'params of container are merged' do
        expect(@mcs[0].group).to eq Poloxy::MERGED_GROUP
        expect(@mcs[0].level).to eq @mcs[1].level
        expect(@mcs[0].total_num).to eq 2
        expect(@mcs[0].item_num).to eq 2
        expect(@mcs[0].group_items).to eq({
          'group1' => {
            'item1' => { num: 1, level: 2 },
          },
          'group2' => {
            'item2' => { num: 1, level: 3 },
          },
        })
      end
    end

    context '2nd merge' do
      before :context do
        @mcs[0].merge @mcs[2]
      end
      it 'params of container are merged' do
        expect(@mcs[0].group).to eq Poloxy::MERGED_GROUP
        expect(@mcs[0].level).to eq @mcs[2].level
        expect(@mcs[0].total_num).to eq 3
        expect(@mcs[0].item_num).to eq 3
        expect(@mcs[0].group_items).to eq({
          'group1' => {
            'item1' => { num: 1, level: 2 },
          },
          'group2' => {
            'item2' => { num: 1, level: 3 },
          },
          'group3' => {
            'item3' => { num: 1, level: 4 },
          },
        })
      end
    end
  end
end
