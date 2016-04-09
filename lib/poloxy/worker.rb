require_relative '../poloxy'

class Poloxy::Worker

  def initialize
    @config      = Poloxy::Config.new
    @logger      = Poloxy::Logging.logger config: @config.log
    @buffer      = Poloxy::Buffer.new config: @config, role: :server
    @datastore   = Poloxy::DataStore.new config: @config.database, logger: @logger
    @datastore.connect
    @data_model  = Poloxy::DataModel.new
    @graph       = Poloxy::Graph.new config: @config.graph, logger: @logger
    @deliver     = Poloxy::Deliver.new logger: @logger
    @item_merger = Poloxy::ItemMerge.new config: @config.deliver['item']
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
      list    = @data_model.where('Item', id: item_ids)
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
          node = @graph.node! msg.group
          msg.node_id = node.id
          msg.save
          level = node.update_level_by_item msg.level, msg.item
          @graph.update_node_level node if level > 0
        end
        @data_model.where(
          'Item', id: msg.items.map(&:id)
        ).update(message_id: msg.id)
      end
      sleep @interval
    end
    Signal.trap :INT, :DEFAULT
  end

  private

    def sighandler sym=:shutdown
      @sighandlers ||= {
        shutdown: Proc.new { |sig|
          p "Signal #{sig} trapped. Exiting ..." if ENV['POLOXY_DEBUG']
          @running = false
        },
      }
      @sighandlers[sym]
    end
end
