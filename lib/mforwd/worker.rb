require_relative '../mforwd'

class MForwd::Worker
  def initialize
    @config = MForwd::Config.new
    redis   = Redis.new url: @config.worker['redis_url'], driver: :hiredis
    @redis  = Redis::Namespace.new(:mforwd, redis: redis)
    @interval = 10
  end

  def run
    Signal.trap :INT, sighandler(:shutdown)
    @running = true
    @cnt = 0
    while @running
      @cnt += 1
      p @cnt
      sleep @interval
    end
    Signal.trap :INT, :DEFAULT
  end

  private

    def sighandler sym=:shutdown
      @sighandlers ||= {
        shutdown: Proc.new { |sig|
          p "called #{sig}"
          @running = false
        },
      }
      @sighandlers[sym]
    end
end
