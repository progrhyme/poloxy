module Poloxy::Function::Expirable
  def expired? now: Time.now
    self.expire_at < now
  end
end
