require 'spec_helper'

class Tester
  include Poloxy::GroupFunction
  def initialize
    @config = TestPoloxy.config
  end
end

describe Poloxy::GroupFunction do
  before :context do
    @t = Tester.new
  end

  describe '#str2group_one' do
    {
      ''             => nil,
      '/ / &%$'      => nil,
      'Foo'          => 'foo',
      ' F oO123 '    => 'foo123',
      '/path/to/dir' => 'pathtodir',
      'Bar.baz-1_2'  => 'bar.baz-1_2',
    }.each do |str, group|
      it "'#{str}' => #{group.inspect}" do
        expect(@t.str2group_one(str)).to eq group
      end
    end
  end

  describe '#str2group_path' do
    {
      ''               => nil,
      '/'              => nil,
      '/^&/'           => nil,
      'foo'            => 'foo',
      'foo/bar'        => 'foo/bar',
      '/foo/bar/'      => 'foo/bar',
      ' /f oo/bar/ '   => 'foo/bar',
      '+*/f=]|oo/b ar' => 'foo/bar',
    }.each_pair do |str, group|
      it "given '#{str}' - Node#group => '#{group}'" do
        expect(@t.str2group_path(str)).to eq group
      end
    end
  end
end
