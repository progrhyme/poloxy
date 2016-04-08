class MForwd::Deliver::Slack < MForwd::Deliver::HttpPost

  @@color_of_kind = {
    'good'    => /^(green$|ok$|good$|recover)/i,
    'warning' => /^(yellow$|warn)/i,
    'danger'  => /^(red$|fatal$|crit|error$|danger$)/i,
  }

  private

  # @param message [MForwd::DataModel::Message]
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
    @@color_of_kind.find { |col, regexp|
      regexp.match message.kind
    }.tap do |col, regexp|
      param[:attachments][0][:color] = col
    end
    param.to_json
  end
end
