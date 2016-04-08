class MForwd::ItemMerge::Summary < MForwd::ItemMerge::Base

  # @param name [String] MForwd::DataModel::Item#name
  # @param stash [Hash] MForwd::DataModel::Item#name
  #  => Hash of Array of MForwd::DataModel::Item
  def merge_items name, stash
    params = {
      'items' => [],
    }

    stash.first[1].first.tap do |item|
      %w[kind type address].each do |key|
        params[key] = item.send(key)
      end
    end

    kinds = stash.keys
    if kinds.size == 1
      list = params['items'] = stash.first[1]
      params['title'] = '%s / %s' % [kinds.first, name]
      params['body']  = <<"EOMSG"
#{list.length} messages
----
#{list.first.message}
EOMSG
    else
      params['title'] = '%s+ / %s' % [kinds.last, name]
      messages = []
      stash.each_pair do |kind, list|
        messages << <<"EOMSG"
#{kind} #{list.length} messages

#{list.first.message}
EOMSG
        params['items'].concat(list)
      end
      params['body'] = messages.join "====\n"
    end

    params['created_at'] = Time.now
    @data_model.spawn 'Message', params
  end

  private :merge_items
end
