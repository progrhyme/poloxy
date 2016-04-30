require 'spec_helper'

class Tester
  include Poloxy::ViewHelper
  def initialize
    @config = TestPoloxy.config
  end
  private
    def config
      @config
    end
end

describe Poloxy::ViewHelper do
  before :context do
    @c = TestPoloxy.config
    @t = Tester.new
  end

  describe '#title_with_level' do
    context 'When argument level is lower or equal to max level' do
      it 'returns only label' do
        expect( @t.title_with_level 3 ).to eq @c.view['title'][3]
      end
    end

    context 'When argument level is over max level' do
      it 'returns label with level' do
        expect( @t.title_with_level 10 ).to eq '%s (Level %d)' % [ @c.view['title'][8], 10 ]
      end
    end
  end

  describe '#abbrev_with_level' do
    context 'When argument level is lower or equal to max level' do
      it 'returns only label' do
        expect( @t.abbrev_with_level 3 ).to eq @c.view['abbrev'][3]
      end
    end

    context 'When argument level is over max level' do
      it 'returns label with level' do
        expect( @t.abbrev_with_level 10 ).to eq '%s(Lv%d)' % [ @c.view['abbrev'][8], 10 ]
      end
    end
  end
end
