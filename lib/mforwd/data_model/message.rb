class MForwd::DataModel::Message < Sequel::Model(:messages)
  attr_accessor :items
end
