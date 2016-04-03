class MForwd::Item::Merge::Summary < MForwd::Item::Merge::Base
  # @param stash [Hash] MForwd::Item#id => Hash of Array of MForwd::Item
  def merge_items id, stash
    params = {}

    kinds = stash.keys
    if kinds.size == 1
      list = stash.fetch(kinds.first)
      params['title'] = '%s / %s' % [kinds.first, id]
      params['body']  = <<"EOMSG"
#{list.length} messages
----
#{list.first.message}
EOMSG
    else
      params['title'] = '%s+ / %s' % [kinds.last, id]
      messages = []
      stash.each_pair do |kind, list|
        messages << <<"EOMSG"
#{kind} #{list.length} messages

#{list.first.message}
EOMSG
      end
      params['body'] = messages.join "====\n"
    end

    MForwd::Message.new params
  end

  private :merge_items
end
