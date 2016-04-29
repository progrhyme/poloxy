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

  def message_to_view message
    vm = Poloxy::ViewModel::Message.from_data message
    vm.level_text = title_with_level message.level
    vm.style      = view_alert_params(level: message.level)[:style]
    vm
  end

  def item_to_view item
    vm = Poloxy::ViewModel::Item.from_data item
    vm.level_text = title_with_level item.level
    vm.style      = view_alert_params(level: item.level)[:style]
    vm
  end
end
