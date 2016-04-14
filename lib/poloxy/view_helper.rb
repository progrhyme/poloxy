module Poloxy::ViewHelper
  def title_by_level level, config: config()
    param_by_level(config.view['title'], level)
  end

  def abbrev_by_level level, config: config()
    param_by_level(config.view['abbrev'], level)
  end

  def abbrev_and_level level, config: config()
    return paramlv_by_level(config.view['abbrev'], level)
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
