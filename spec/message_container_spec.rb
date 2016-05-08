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
        item:      items.first.name,
        group:     items.first.group,
        level:     items.map(&:level).max,
        expire_at: Time.now + 3600,
        items:     items,
      }
    }
  end

  describe '#append(message)' do
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
        i1  = @itm.call('bar', 'generic', 4)
        i2  = @itm.call('baz', 'generic', 5)
        @m2 = @msg.call([ i1, i2 ])
        @mc.append @m2
      end

      it 'params of message are merged' do
        expect(@mc.group).to eq Poloxy::MERGED_GROUP
        %w[level expire_at].each do |key|
          expect( @mc.send(key) ).to eq @m2.send(key)
        end
        expect(@mc.total_num).to eq 2
        expect(@mc.item_num).to eq 3
        expect(@mc.group_items).to eq({
          @m.group => {
            @m.item => { num: 1, level: @m.level },
          },
          @m2.group => {
            @m2.item => { num: 2, level: @m2.level },
          },
        })
      end
    end

    context 'When given message is snoozed' do
      before :context do
        @mc2 = Poloxy::MessageContainer.new TestPoloxy.config
        @m.is_snoozed = true
        @mc2.append @m
      end

      it 'message is appended to @snoozed' do
        expect(@mc2.snoozed).to eq [@m]
      end

      it 'params of messages are not merged' do
        %w[total_num kind_num item_num].each do |key|
          expect( @mc2.send(key) ).to eq 0
        end
        expect(@mc2.messages).to eq []
      end
    end
  end

  describe '#merge(other)' do
    before :context do
      @snoozed = []
      @mcs = (1..3).map do |i|
        mc  = Poloxy::MessageContainer.new(TestPoloxy.config)
        itm = @itm.call("item#{i}", "group#{i}", i + 1)
        mc.append( @msg.call([ itm ]) )

        itm_snoozed = @itm.call("snooze#{i}", "snoozed#{i}", i + 1)
        snoozed = @msg.call([ itm_snoozed ])
        snoozed.is_snoozed = true
        mc.append snoozed
        @snoozed << snoozed

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
        expect(@mcs[0].snoozed).to eq @snoozed[0..1]
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
        expect(@mcs[0].snoozed).to eq @snoozed
      end
    end
  end

  describe '#unify' do
    before :context do
      @msgs = (1..3).map do |i|
        items = 1.upto(i).map do |j|
          @itm.call("item#{i}", "group#{i}", i + j)
        end
        @msg.call items
      end
    end

    context 'Given messages in the same group' do
      before :context do
        @mc = Poloxy::MessageContainer.new TestPoloxy.config
        @mc.append @msgs[0]
        @mc.append( @msgs[0].dup.tap { |m| m.item = "#{m.item}.dup";  m.level = 5 } )
        @mc0 = @mc.dup
        @mc.unify
        @um = @mc.messages[0]
      end

      it 'unified into single message' do
        expect(@mc.messages.length).to eq 1
        expect(@mc.total_num).to eq 1
      end

      it 'groups of unified message and container is same to original' do
        grp = @msgs[0].group
        [ @mc.group, @um.group ].each do |g|
          expect(g).to eq grp
        end
        expect(@um.title).to match /\(#{grp}\) 2 Alerts via POLOXY$/
      end

      it 'unified level is max of original messages' do
        [ @mc.level, @um.level ].each do |lv|
          expect(lv).to eq( [@msgs[0].level, 5].max )
        end
      end

      %w[item_num kind_num group_items].each do |key|
        it %Q|@#{key} don't change| do
          expect(@mc.send(key)).to eq(@mc0.send(key))
        end
      end

      it 'original messages are converted to @undelivered' do
        expect(@mc.undelivered).to eq(@mc0.messages)
      end

      it 'unified message body contains info of original alerts' do
        [
          /There are 2 items of 2 kinds of 1 groups\./,
          /\[#{@msgs[0].group}\]/,
          /- #{@msgs[0].item} : 1 items, last = /,
          /- #{@msgs[0].item}\.dup : 1 items, last = /,
        ].each do |ptn|
          expect(@um.body).to match ptn
        end
      end
    end

    context 'Given messages in different groups' do
      before :context do
        @mc = Poloxy::MessageContainer.new TestPoloxy.config
        @mc.append @msgs[0]
        @mc.append @msgs[1]
        @mc0 = @mc.dup
        @mc.unify
        @um = @mc.messages[0]
      end

      it "groups of unified message and container is '#{Poloxy::MERGED_GROUP}'" do
        grp = Poloxy::MERGED_GROUP
        [ @mc.group, @um.group ].each do |g|
          expect(g).to eq grp
        end
        expect(@um.title).to match /\(#{grp}\) 3 Alerts via POLOXY$/
      end

      it 'unified level is max of original messages' do
        lv_to_be = [ @msgs[0].level, @msgs[1].level ].max
        [ @mc.level, @um.level ].each do |lv|
          expect(lv).to eq lv_to_be
        end
      end

      %w[item_num kind_num group_items].each do |key|
        it %Q|@#{key} don't change| do
          expect(@mc.send(key)).to eq(@mc0.send(key))
        end
      end

      it 'unified message body contains info of original alerts' do
        [
          /There are 3 items of 2 kinds of 2 groups\./,
          /\[#{@msgs[0].group}\]/,
          /\[#{@msgs[1].group}\]/,
          /- #{@msgs[0].item} : 1 items, last = /,
          /- #{@msgs[1].item} : 2 items, last = /,
        ].each do |ptn|
          expect(@um.body).to match ptn
        end
      end

      context 'When #unify again after #append' do
        before :context do
          @mc.append @msgs[2]
          @mc0 = @mc.dup
          @mc.unify
          @um = @mc.messages[0]
        end

        it "groups of unified message and container is '#{Poloxy::MERGED_GROUP}'" do
          grp = Poloxy::MERGED_GROUP
          [ @mc.group, @um.group ].each do |g|
            expect(g).to eq grp
          end
          expect(@um.title).to match /\(#{grp}\) 6 Alerts via POLOXY$/
        end

        it 'unified level is max of (original and appended messages)' do
          lv_to_be = [ @mc0.level, @msgs[2].level ].max
          [ @mc.level, @um.level ].each do |lv|
            expect(lv).to eq lv_to_be
          end
        end

        %w[item_num kind_num group_items].each do |key|
          it %Q|@#{key} don't change| do
            expect(@mc.send(key)).to eq(@mc0.send(key))
          end
        end

        it 'unified message body contains info of original and appended alerts' do
          [
            /There are 6 items of 3 kinds of 3 groups\./,
            /\[#{@msgs[0].group}\]/,
            /\[#{@msgs[1].group}\]/,
            /\[#{@msgs[2].group}\]/,
            /- #{@msgs[0].item} : 1 items, last = /,
            /- #{@msgs[1].item} : 2 items, last = /,
            /- #{@msgs[2].item} : 3 items, last = /,
          ].each do |ptn|
            expect(@um.body).to match ptn
          end
        end

        it '@undelivered messages are not lost' do
          expect(@mc.undelivered).to eq(@mc0.undelivered.push @msgs[2])
        end
      end
    end
  end
end
