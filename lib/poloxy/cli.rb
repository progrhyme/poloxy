require 'thor'

require_relative '../poloxy'

class Poloxy::CLI < Thor

  package_name "poloxy-cli"
  class_option :config, :aliases => 'c'

  desc 'purge', 'Purge old expired data'
  option :time, aliases: 't'
  def purge
    init options[:config]

    keep = options[:time] || @config.data['default_keep_period']
    if keep.class != Fixnum
      keep = ChronicDuration.parse keep
    end
    before = Time.now - keep

    dm = {}
    %w[Item Message GraphNode NodeLeaf].each do |table|
      dm[table] = @dm.load_class table
    end
    messages_to_purge = dm['Message'].where { expire_at < before }
    message_ids = messages_to_purge.map(&:id)
    dm['Item'].where(message_id: message_ids).delete
    dm['Item'].where(message_id: Poloxy::SNOOZED_MESSAGE_ID).where {
      expire_at < before
    }.delete
    messages_to_purge.delete

    nodes_to_purge = dm['GraphNode'].where { expire_at < before }
    node_ids = nodes_to_purge.map(&:id)
    dm['NodeLeaf'].where(node_id: node_ids).delete
    nodes_to_purge.delete
  end

  private

  def init conf=nil
    c = config(conf)
    @logger = Poloxy::Logging.logger config: c.log
    Poloxy::DataStore.new(config: c.database, logger: @logger).connect
    @dm = Poloxy::DataModel.new
  end

  def config path=nil
    @config ||= lambda {
      args = {}
      args[:path] = path if path
      Poloxy::Config.new *args
    }.call
  end
end
