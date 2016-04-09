module Poloxy::WebAPI::Functions
  def log
    @log ||= Poloxy::Logging.logger config: config.log
  end

  def ctx
    @ctx ||= Poloxy::WebAPI::Context.new config: config, log: log
  end
end
