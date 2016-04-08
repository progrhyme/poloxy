class MForwd::DataModel
  def initialize
    @classes = {}
  end

  # @param klass [String] model class
  def spawn klass, *args
    load_class(klass).new *args
  end

  def load_class klass
    @classes[klass] ||= Proc.new {
      file = klass.extend(CamelSnake).to_snake
      require_relative "data_model/#{file}"
      Object.const_get("MForwd::DataModel::#{klass}")
    }.call
  end
end
