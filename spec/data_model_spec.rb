require 'spec_helper'

klass = Poloxy::DataModel
describe klass do
  it 'Can .new' do
    expect(klass.new).to be_an_instance_of klass
  end
  describe '#load_class' do
    files = File.join(File.dirname(__FILE__), '..', 'lib/poloxy/data_model/*.rb')
    Dir[files].each do |f|
      klss = f.gsub(%r|[^/]*/|, '').sub(
        /^([^\.]+)\.rb$/, '\1').extend(CamelSnake).to_camel
      it "can load #{klss}" do
        expect(klass.new.load_class klss).to be(
          Object.const_get "Poloxy::DataModel::#{klss}")
      end
    end
  end
end
