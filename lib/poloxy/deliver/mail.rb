class Poloxy::Deliver::Mail < Poloxy::Deliver::Base

  def initialize config: nil, logger: nil
    super config: config, logger: logger
    Mail.defaults do
      delivery_method :smtp, address: config.smtp['host'], port: config.smtp['port']
    end
  end

  # @param message [Poloxy::DataModel::Message]
  def deliver message
    misc = message.get_misc['mail'] || {}
    params = {
      from: make_from(misc),
    }
    mail = Mail.new do
      from    params[:from]
      to      message.address
      subject message.title
      body    message.body
    end
    %w[cc bcc].each do |field|
      if misc[field]
        mail.send(field, misc[field])
      end
    end

    write_log "Send mail - #{mail.to_s}", :debug

    mail.deliver
    write_log 'Sent mail - from:%s, to:%s, subject:%s' % [ mail.from, mail.to, mail.subject ]
  end

  private

    def make_from misc
      misc['from'] || '%s@%s' % [
        @config.deliver['mail']['default_from'], Socket.gethostname ]
    end
end
