require_relative '../mforwd'

class MForwd::Worker

  def initialize
    @config      = MForwd::Config.new
    @logger      = MForwd::Logging.logger config: @config.log
    @buffer      = MForwd::Buffer.new config: @config, role: :server
    @datastore   = MForwd::DataStore.new config: @config.database, logger: @logger
    @datastore.connect
    @data_model  = MForwd::DataModel.new
    @deliver     = MForwd::Deliver.new logger: @logger
    @item_merger = MForwd::ItemMerge.new config: @config.deliver['item']
    @interval    = 5
  end

  def run
    Signal.trap :INT, sighandler(:shutdown)
    @running = true
    @waiting = 0
    while @running
      item_ids = @buffer.pop_all
      if item_ids.empty?
        @waiting += 1
        @logger.debug "#{@waiting} No queue in buffer."
        sleep @interval
        next
      end

      @logger.debug "Queued in buffer. wait interval"
      @waiting = 0
      sleep @config.deliver['min_interval']

      item_ids.concat(@buffer.pop_all)
      item_dm = @data_model.load_class('Item')
      list    = item_dm.where(id: item_ids)
      @logger.debug "Fetched from buffer:\n  #{list}"
      messages = @item_merger.merge_into_messages list
      @logger.debug "Messages to deliver:\n  #{messages}"
      messages.each do |msg|
        begin
          @deliver.deliver msg
          msg.delivered_at = Time.now
        rescue => e
          @logger.error "Failed to deliver! Error: #{e}"
        ensure
          msg.save
        end
        item_dm.where(id: msg.items.map(&:id)).update(message_id: msg.id)
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
