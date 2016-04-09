require 'spec_helper'

describe 'Poloxy::DataModel::GraphNode' do
  dm    = Poloxy::DataModel.new
  klass = dm.load_class 'GraphNode'

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
        expect(klass.new.send(:normalize_label, str)).to eq label
      end
    end

  end
end
