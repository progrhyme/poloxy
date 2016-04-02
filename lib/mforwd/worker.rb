require_relative '../mforwd'

class MForwd::Worker
  def initialize
    @config = MForwd::Config.new
    @buffer = MForwd::Buffer.new config: @config, role: :server
    @interval = 5 # DEVELOP
    #@interval = 15
  end

  def run
    Signal.trap :INT, sighandler(:shutdown)
    @running = true
    @cnt = 0
    while @running
      @cnt += 1
      data = @buffer.pop_all
      p "#{@cnt} #{data.inspect}"
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
