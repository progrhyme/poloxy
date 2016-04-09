require 'spec_helper'

describe 'Poloxy::DataModel::GraphNode' do
  dm = Poloxy::DataModel.new
  it 'Can load class' do
    expect(dm.load_class 'GraphNode').to be Poloxy::DataModel::GraphNode
  end
end
