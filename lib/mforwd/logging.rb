module MForwd::Logging

  # @return [Logger::WithStdout]
  def self.logger config: nil
    return @logger if @lgger

    config ||= MForwd::Config.new.log

    @logger = StdLogger.create(
      config['file'],
      shift_age:   config['rotate'] || 0,
      allow_nodev: true,
    )
    @logger.level     = Object.const_get("Logger::#{config['level']}")
    @logger.progname  = [$0, ARGV].join(%q[ ])
    @logger.formatter = proc do |level, date, prog, msg|
      "#{date} [#{level}] #{msg} -- #{prog}\n"
    end
    @logger
  end
end
