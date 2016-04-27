module Poloxy::WebAPI::View
  include Poloxy::ViewHelper

  def group_to_breadcrumb group, base: '', config: config()
    list = [ { name: '/', path: base } ]
    _group = group.sub %r|^/|, ''
    _group.split(config.graph['delimiter']).each do |label|
      path = "#{base}#{label}"
      list << { name: label, path: path }
      base = "#{path}/"
    end
    list
  end

  def view_alert_params level: Poloxy::MIN_LEVEL, config: config()
    c_style = config.web['style']
    params = {
      :style => {
        :alert => param_by_level(c_style['alert'], level),
        :color => param_by_level(c_style['color'], level),
        :icon  => param_by_level(c_style['icon'],  level),
      },
      :title => title_by_level(level, config: config)
    }
  end

  def view_styles config: config()
    { :box => config.web['style']['box'] }
  end
end
