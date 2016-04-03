module MForwd::Logging

  # @return [Logger]
  def logger config: nil
    return @logger if @lgger

    config ||= MForwd::Config.new.log

    outs = []
    outs << STDOUT if STDOUT.tty?
    outs << File.open(config['file'], 'a') if config['file']
    if outs.empty?
      outs << File.open('/dev/null', 'a')
    end

    @logger = Logger.new( MultiIO.new(outs), config['rotate'] || 0 ).tap do |lg|
      lg.level     = Object.const_get("Logger::#{config['level']}")
      lg.progname  = [$0, ARGV].join(%q[ ])
      lg.formatter = proc do |level, date, prog, msg|
        "#{date} [#{level}] #{msg} -- #{prog}\n"
      end
    end
  end

  class MultiIO
    def initialize targets
      @targets = targets
    end

    def write *args
      @targets.each { |t| t.write(*args) }
    end

    def close
      @targets.each { |t| t.close }
    end
  end
end
