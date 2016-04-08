class Poloxy::Deliver::Slack < Poloxy::Deliver::HttpPost

  private

  # @param message [Poloxy::DataModel::Message]
  def create_body message
    param = {
      attachments: [{
        fallback: "#{message.title}\n#{message.body}",
        fields: [{
          title: message.title,
          value: message.body,
        }],
      }],
    }
    level2color(message.level).tap do |col|
      param[:attachments][0][:color] = col
    end
    param.to_json
  end

  def level2color level
    case level
    when 1
      'good'
    when 3
      'warning'
    when 5
      'danger'
    end
  end
end
