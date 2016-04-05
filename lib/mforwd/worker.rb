require_relative '../mforwd'

class MForwd::Worker
  include MForwd::Logging

  def initialize
    @config      = MForwd::Config.new
    @logger      = logger config: @config.log
    @buffer      = MForwd::Buffer.new config: @config, role: :server
    @deliver     = MForwd::Deliver.new logger: @logger
    @item_merger = MForwd::Item::Merge.new config: @config.deliver['item']
    @interval    = 5
  end

  def run
    Signal.trap :INT, sighandler(:shutdown)
    @running = true
    @waiting = 0
    while @running
      data = @buffer.pop_all
      if data.empty?
        @waiting += 1
        @logger.debug "#{@waiting} No queue in buffer."
        sleep @interval
        next
      end

      @logger.debug "Queued in buffer. wait interval"
      @waiting = 0
      sleep @config.deliver['min_interval']

      data.concat(@buffer.pop_all)
      list = data.map do |d|
        MForwd::Item.decode(d)
      end
      @logger.debug "Fetched from buffer:\n  #{list}"
      messages = @item_merger.merge_into_messages list
      @logger.debug "Messages to deliver:\n  #{messages}"
      messages.each do |msg|
        @deliver.deliver msg
      end
      sleep @interval
    end
    Signal.trap :INT, :DEFAULT
  end

  private

    def sighandler sym=:shutdown
      @sighandlers ||= {
        shutdown: Proc.new { |sig|
          p "Signal #{sig} trapped. Exiting ..." if ENV['MFORWD_DEBUG']
          @running = false
        },
      }
      @sighandlers[sym]
    end
end
