module Poloxy::Function::Group
  def str2group_path str
    dlm = config().graph['delimiter']
    group = str.split(/#{dlm}+/).map { |s|
      str2group_one s
    }.select { |s| s }.join dlm
    group if group.length > 0
  end

  def str2group_one str
    single = str.downcase.scan(/[\w\-\.]+/).join
    single if single.length > 0
  end

  def merge_groups groups
    dlm = config().graph['delimiter']
    common_labels = []
    labels_list = groups.map { |g| g.split dlm }
    loop do
      uniqs = labels_list.map(&:shift).uniq
      if uniqs.length > 1
        break
      elsif uniqs.first
        common_labels << uniqs.first
      else
        break
      end
    end
    if common_labels.empty?
      Poloxy::MERGED_GROUP
    else
      common_labels.join(dlm)
    end
  end
end
