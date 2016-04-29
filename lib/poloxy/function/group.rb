module Poloxy::Function::Group
  def str2group_path str
    dlm = @config.graph['delimiter']
    group = str.split(/#{dlm}+/).map { |s|
      str2group_one s
    }.select { |s| s }.join dlm
    group if group.length > 0
  end

  def str2group_one str
    single = str.downcase.scan(/[\w\-\.]+/).join
    single if single.length > 0
  end
end
