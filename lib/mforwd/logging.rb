module MForwd::Logging

  # @return [Logger::WithStdout]
  def logger config: nil
    return @logger if @lgger

    config ||= MForwd::Config.new.log

    # Returns dummy logger object if no log destination available
    if !$stdout.tty? and !config['file']
      @logger = Class.new { def method_missing *args; nil; end }.new
      return @logger
    end

    @logger = StdLogger.create(
      config['file'],
      shift_age: config['rotate'] || 0,
    )
    @logger.level     = Object.const_get("Logger::#{config['level']}")
    @logger.progname  = [$0, ARGV].join(%q[ ])
    @logger.formatter = proc do |level, date, prog, msg|
      "#{date} [#{level}] #{msg} -- #{prog}\n"
    end
    @logger
  end
end
