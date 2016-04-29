class Poloxy::DataModel::Message < Sequel::Model
  include Poloxy::Function::Expirable
  attr_accessor :items
end
