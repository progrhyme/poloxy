class Poloxy::ItemMerge::Summary < Poloxy::ItemMerge::Base

  # @param name [String] Poloxy::DataModel::Item#name
  # @param stash [Hash] Poloxy::DataModel::Item#name
  #  => Hash of Array of Poloxy::DataModel::Item
  def merge_items name, stash
    params = {
      'items' => [],
    }

    stash.first[1].first.tap do |item|
      %w[level group type address].each do |key|
        params[key] = item.send(key)
      end
    end

    levels = stash.keys
    if levels.size == 1
      list = params['items'] = stash.first[1]
      params['title'] = '%s / %s' % [levels.first, name]
      params['body']  = <<"EOMSG"
#{list.length} messages
----
#{list.first.message}
EOMSG
    else
      params['title'] = '%s+ / %s' % [levels.last, name]
      messages = []
      stash.each_pair do |level, list|
        messages << <<"EOMSG"
Level #{level}: #{list.length} messages

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
