require 'spec_helper'

require 'poloxy/worker'

describe Poloxy::Worker do
  before :context do
    @worker = Poloxy::Worker.new config: TestPoloxy.config
  end

  it 'Can initialize' do
    expect(@worker).to be_an_instance_of Poloxy::Worker
  end
end
