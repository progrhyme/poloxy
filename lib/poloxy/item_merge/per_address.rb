class Poloxy::ItemMerge::PerAddress < Poloxy::ItemMerge::Base
  include Poloxy::ItemMerge::Function

  private
    def merge_items data
      merge_items_template data, per: :address
    end
end
