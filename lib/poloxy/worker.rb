require_relative '../poloxy'

class Poloxy::Worker

  def initialize config: nil
    @config      = config || Poloxy::Config.new
    @logger      = Poloxy::Logging.logger config: @config.log
    @datastore   = Poloxy::DataStore.new config: @config.database, logger: @logger
    @datastore.connect
    @data_model  = Poloxy::DataModel.new
    @graph       = Poloxy::Graph.new config: @config.graph, logger: @logger
    @deliver     = Poloxy::Deliver.new logger: @logger
    @item_merger = Poloxy::ItemMerge.new config: @config
    @interval    = 5
  end

  def run
    Signal.trap :INT, sighandler(:shutdown)
    @running = true
    @waiting = 0
    item_dm = @data_model.load_class 'Item'
    while @running
      item_on_top = item_dm.where.reverse_order(:id).limit(1).first
      if ! item_on_top || item_on_top.message_id != 0
        @waiting += 1
        @logger.debug "#{@waiting} No undelivererd items."
        sleep @interval
        next
      end

      @logger.debug "Queued in buffer. wait interval"
      @waiting = 0
      sleep @config.deliver['min_interval']

      items = item_dm.where(message_id: 0)
      @logger.debug "Fetched from buffer:\n  #{items}"

      mcontainer = @item_merger.merge_into_messages items

      @logger.debug "Messages undelivered:\n  #{mcontainer.undelivered}"
      mcontainer.undelivered.each do |msg|
        node = @graph.node! msg.group
        node.update_leaf msg
        @graph.update_node node
      end

      @logger.debug "Messages to deliver:\n  #{mcontainer.messages}"
      mcontainer.messages.each do |msg|
        begin
          @deliver.deliver msg
          msg.delivered_at = Time.now
        rescue => e
          @logger.error "Failed to deliver! Error: #{e}"
        ensure
          if msg.item != Poloxy::MERGED_ITEM
            node = @graph.node! msg.group
            msg.node_id = node.id
            node.update_leaf msg
            @graph.update_node node
          end
          msg.node_id ||= 0
          msg.save
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
