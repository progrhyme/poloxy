class MForwd::Item::Merge
  def self.merge list, method: :base
    require "mforwd/item/merge/#{method}"
    klass = Object.const_get('MForwd::Item::Merge::%s' % [method.capitalize])
    merger = klass.new
    merger.merge list
  end
end
