# Factory and Delegator for DataModel Objects
class Poloxy::DataModel
  def initialize
    @classes = {}
  end

  # @param klass [String] model class
  def spawn klass, *args
    load_class(klass).new *args
  end

  def find klass, *args
    load_class(klass)[*args]
  end

  def where klass, *args
    load_class(klass).where *args
  end

  def all klass
    load_class(klass).all
  end

  def load_class klass
    @classes[klass] ||= Proc.new {
      file = klass.extend(CamelSnake).to_snake
      require_relative "data_model/#{file}"
      Object.const_get("Poloxy::DataModel::#{klass}")
    }.call
  end
end
