class Poloxy::DataModel::Message < Sequel::Model
  include Poloxy::Function::Expirable
  attr_accessor :items, :is_snoozed

  def get_misc
    JSON.parse self.misc || '{}'
  end

  def snoozed?
    self.is_snoozed
  end
end
