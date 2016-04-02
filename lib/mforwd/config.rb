class MForwd::Config
  @@default = {
    #min_interval: 60,
    min_interval: 10, ## For Development
  }

  def initialize path: ENV['MFORWD_CONFIG'] || '.mforwd.toml'
    @mine = File.readable?(path) ? TOML.load_file(path) : {}
  end

  def method_missing method
    if @mine.has_key? method.to_s
      @mine[method.to_s]
    elsif @@default.has_key? method.to_sym
      @@default[method.to_sym]
    end
  end
end
