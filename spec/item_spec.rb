require 'spec_helper'

describe Poloxy::Item do
  before :context do
    @i = Poloxy::Item.new config: TestPoloxy.config
  end

  describe '#create' do
    context 'If optional arguments are omitted' do
      it 'set default group and min level' do
        i = @i.create({
          name:        'test alert',
          address:     'anywhere',
          type:        'Print',
          message:     'Something happened!',
          received_at: Time.now,
        })
        expect(i.group).to eq 'default'
        expect(i.level).to eq Poloxy::MIN_LEVEL
      end
    end
  end
end
