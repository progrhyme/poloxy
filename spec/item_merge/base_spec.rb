require 'spec_helper'

class TestItem
  attr :name, :level, :group, :type, :address
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
        [ 'foo',  1, 'a',   'Print',    'dummy'         ], # 0
        [ 'foo',  1, 'a',   'Print',    'dummy'         ], # 1
        [ 'foo',  2, 'a',   'Print',    'dummy'         ], # 2
        [ 'foo2', 1, 'a',   'Print',    'dummy'         ], # 3
        [ 'bar',  1, 'a/b', 'Print',    'dummy'         ], # 4
        [ 'baz',  1, 'b',   'Print',    'dummy'         ], # 5
        [ 'baz',  1, 'b',   'Print',    'dummy2'        ], # 6
        [ 'baz',  1, 'b',   'Print',    'dummy2'        ], # 7
        [ 'baz',  1, 'b',   'HttpPost', 'example.com'   ], # 8
        [ 'baz',  2, 'b',   'HttpPost', 'example.com'   ], # 9
        [ 'cuz',  1, 'b/c', 'HttpPost', 'example.com'   ], # 10
        [ 'cuz',  1, 'b/c', 'HttpPost', 'example-2.com' ], # 11
      ].map do |arr|
        TestItem.new({
          name: arr[0], level:   arr[1], group: arr[2],
          type: arr[3], address: arr[4]
        })
      end
    }
    it "returns nested structured Hash" do
      ret = @im.send(:pre_merge_items, list)
      expect(ret).to eq({
        'Print' => {
          'dummy' => {
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
          },
          'dummy2' => {
            'b' => {
              :items => {
                'baz' => {
                  1 => [ list[6], list[7] ],
                },
              },
            },
          },
        },
        'HttpPost' => {
          'example.com' => {
            'b' => {
              :items => {
                'baz' => {
                  1 => [ list[8] ],
                  2 => [ list[9] ],
                },
              },
              'c' => {
                :items => {
                  'cuz' => {
                    1 => [ list[10] ],
                  },
                },
              },
            },
          },
          'example-2.com' => {
            'b' => {
              'c' => {
                :items => {
                  'cuz' => {
                    1 => [ list[11] ],
                  },
                },
              },
            },
          },
        },
      })
    end
  end
end
