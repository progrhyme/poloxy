class MForwd::Deliver::HttpPost < MForwd::Deliver::Base

  # @param message [MForwd::Message]
  def deliver message
    url  = URI.parse(message.address)
    post = Net::HTTP::Post.new(url.path).tap do |post|
      post['Content-Type'] = 'application/json'
      post.body = { text: message.body }.to_json
    end
    http = Net::HTTP.new(url.host, url.port).tap do |http|
      http.use_ssl = true
      #http.set_debug_output $stderr if ENV['MFORWD_DEBUG']
    end
    res = http.request post
    case res
    when Net::HTTPSuccess
      @logger.info "OK. #{res.code}" if @logger
    else
      @logger.error "Error! #{res.code}, #{res.message}, #{res.body}" if @logger
    end
    @logger.debug "Sent #{message}" if @logger
  end
end
