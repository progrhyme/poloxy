require 'spec_helper'

class Tester
  include Poloxy::Function::Group
  def initialize
    @config = TestPoloxy.config
  end
  private
    def config
      @config
    end
end

describe Poloxy::Function::Group do
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

  describe '#merge_groups' do
    context 'With 2 groups' do
      {
        %w[default     default]     => 'default',
        %w[default/foo default]     => 'default',
        %w[default/foo default/bar] => 'default',
        %w[default/foo default/foo] => 'default/foo',
        %w[default     foo]         => Poloxy::MERGED_GROUP,
      }.each_pair do |groups, ret_g|
        it "merge #{groups} => '#{ret_g}'" do
          expect(@t.merge_groups groups).to eq ret_g
        end
      end
    end

    context 'With 3 groups' do
      {
        %w[default     default     default]     => 'default',
        %w[default/foo default     default]     => 'default',
        %w[default/foo default/bar default/baz] => 'default',
        %w[default/foo default/foo default/foo] => 'default/foo',
        %w[default     default     foo]         => Poloxy::MERGED_GROUP,
      }.each_pair do |groups, ret_g|
        it "merge #{groups} => '#{ret_g}'" do
          expect(@t.merge_groups groups).to eq ret_g
        end
      end
    end
  end
end
