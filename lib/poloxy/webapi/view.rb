module Poloxy::WebAPI::View
  def view_alert_params level: Poloxy::MIN_LEVEL, config: nil
    params = {
      'style' => {
        'alert' => param_by_level(config['style']['alert'], level),
        'icon'  => param_by_level(config['style']['icon'],  level),
      },
      'text' => param_by_level(config['text'], level),
    }
  end

  def view_styles config: nil
    { 'box' => config['style']['box'] }
  end

  private

    def param_by_level stash, level=Poloxy::MIN_LEVEL
      before = nil
      stash.each do |lv, val|
        return val    if lv == level
        return before if lv >  level
        before = val
      end
      return before
    end
end
