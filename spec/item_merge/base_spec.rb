require 'spec_helper'

class TestItem
  attr :name, :level, :group
  def initialize stash
    stash.each do |k,v|
      instance_variable_set "@#{k}", v
    end
  end
end

describe Poloxy::ItemMerge::Base do
  before :context do
    @im = Poloxy::ItemMerge::Base.new config: TestPoloxy.config
  end
  describe '#pre_merge_items(list)' do
    let(:list) {
      [
        [ 'foo',  1, 'a'   ],
        [ 'foo',  1, 'a'   ],
        [ 'foo',  2, 'a'   ],
        [ 'foo2', 1, 'a'   ],
        [ 'bar',  1, 'a/b' ],
        [ 'baz',  1, 'b'   ],
      ].map do |arr|
        TestItem.new({ name: arr[0], level: arr[1], group: arr[2] })
      end
    }
    it "returns Hash" do
      ret = @im.send(:pre_merge_items, list)
      expect(ret).to eq({
        'a' => {
          :items => {
            'foo' => {
              1 => [ list[0], list[1] ],
              2 => [ list[2] ],
            },
            'foo2' => {
              1 => [ list[3] ],
            },
          },
          'b' => {
            :items => {
              'bar' => {
                1 => [ list[4] ],
              },
            },
          },
        },
        'b' => {
          :items => {
            'baz' => {
              1 => [ list[5] ],
            },
          },
        },
      })
    end
  end
end
