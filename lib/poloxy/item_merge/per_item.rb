class Poloxy::ItemMerge::PerItem < Poloxy::ItemMerge::Base
  include Poloxy::ItemMerge::Function

  private
    def merge_items data
      merge_items_template data, per: :item
    end
end
