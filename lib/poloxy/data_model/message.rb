class Poloxy::DataModel::Message < Sequel::Model
  include Poloxy::Function::Expirable
  attr_accessor :items

  def get_misc
    JSON.parse self.misc || '{}'
  end
end
