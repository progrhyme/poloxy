require_relative '../mforwd'

class MForwd::Worker
  def initialize
    @config = MForwd::Config.new
    @buffer = MForwd::Buffer.new config: @config, role: :server
    @item_merger = MForwd::Item::Merge.new config: @config.deliver['item']
    @interval = 5
  end

  def run
    Signal.trap :INT, sighandler(:shutdown)
    @running = true
    @waiting = 0
    while @running
      data = @buffer.pop_all
      if data.empty?
        @waiting += 1
        p "#{@waiting} No queue in buffer."
        sleep @interval
        next
      end

      p "Queued in buffer. wait interval"
      @waiting = 0
      sleep @config.deliver['min_interval']

      data.concat(@buffer.pop_all)
      list = data.map do |d|
        MForwd::Item.decode(d)
      end
      p "Fetched from buffer:\n  #{list}"
      messages = @item_merger.merge_into_messages list
      p "Messages to deliver:\n  #{messages}"
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
