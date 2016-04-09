require 'spec_helper'

require 'poloxy/worker'

describe Poloxy::Worker do
  it 'Can initialize' do
    expect(Poloxy::Worker.new).to be_an_instance_of Poloxy::Worker
  end
end
