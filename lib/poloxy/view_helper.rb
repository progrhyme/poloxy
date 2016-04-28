module Poloxy::ViewHelper
  def title_by_level level, config: config()
    param_by_level(config.view['title'], level)
  end

  def abbrev_by_level level, config: config()
    param_by_level(config.view['abbrev'], level)
  end

  def title_and_level level, config: config()
    return paramlv_by_level(config.view['title'], level)
  end

  def abbrev_and_level level, config: config()
    return paramlv_by_level(config.view['abbrev'], level)
  end

  def title_with_level level, config: config()
    title, _level = title_and_level(level, config: config)
    if level == _level
      title
    else
      '%s (Level %d)' % [ title, _level ]
    end
  end

  def seconds_to_time_view sec
    if sec < 60
      '%d sec' %[sec]
    elsif sec < 60 * 60
      min = sec / 60
      '%d min' %[min]
    elsif sec < 60 * 60 * 24
      hour = sec / (60 * 60)
      '%d hours' %[hour]
    else
      day = sec / (60 * 60 * 24)
      '%d days' %[day]
    end
  end

  private

    def param_by_level stash, level=Poloxy::MIN_LEVEL
      param, lv = paramlv_by_level stash, level
      param
    end

    def paramlv_by_level stash, level=Poloxy::MIN_LEVEL
      prev_lv  = nil
      prev_val = nil
      stash.each do |lv, val|
        return val,      lv      if lv == level
        return prev_val, prev_lv if lv >  level
        prev_val, prev_lv = val, lv
      end
      return prev_val, prev_lv
    end
end
