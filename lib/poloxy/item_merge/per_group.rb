class Poloxy::ItemMerge::PerGroup < Poloxy::ItemMerge::Base

  private

  # @param tree [Hash] nested Hash of {Poloxy::DataModel::Item}
  def merge_tree tree
    mcontainer = Poloxy::MessageContainer.new @config
    tree.each_pair do |key, stash|
      next if key == :items
      mcontainer.merge( merge_tree(stash) )
    end
    if tree.has_key? :items
      mcontainer.merge( items_to_message(tree[:items]) )
    end
    mcontainer
  end

  # @param items [Hash{String => Hash}]
  def items_to_message items
    mcontainer = Poloxy::MessageContainer.new @config
    items.each_pair do |name, stash|
      mcontainer.append items2msg(name, stash)
    end
    mcontainer.unify
    mcontainer
  end
end
