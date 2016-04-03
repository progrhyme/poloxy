module MForwd::Util::String
  def str_to_snake str
    str.sub(/^([A-Z])/) { $1.downcase }.
      gsub(/([a-z]*)([A-Z])([a-z]*)/) { '%s_%s%s' % [$1, $2.downcase, $3] }
  end
end
