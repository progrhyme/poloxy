require 'spec_helper'

class Poloxy::Config
  attr_accessor :deliver
end

klass = 'Poloxy::ItemMerge::PerItem'
describe klass do
  before :context do
    @mkcfg = ->(merger){
      config = TestPoloxy.config
      config.deliver = { 'item' => { 'merger' => merger } }
      config
    }
  end

  describe '#new' do
    describe 'Configured "deliver.item.merger" is loaded' do
      %w[PerItem PerGroup PerAddress].each do |klass|
        it "P::ItemMerge::#{klass} is loaded" do
          im = Poloxy::ItemMerge.new config: @mkcfg.call(klass)
          expect(im.merger).to be_an_instance_of(
            Object.const_get("Poloxy::ItemMerge::#{klass}")
          )
        end
      end
    end
  end
end
