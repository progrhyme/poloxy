module Poloxy::Function::Loggable
  def write_log msg=nil, level=:info
    return unless logger()
    logger().send(level, msg)
  end
end
