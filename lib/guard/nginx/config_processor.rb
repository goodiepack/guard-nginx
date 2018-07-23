class ConfigProcessor
  def initialize(options = {})
    @config = options
  end

  def config_fetch(key)
    @config.fetch(key.to_sym) { false }
  end

  def root_path
    Dir.pwd
  end

  def config_path
    "#{root_path}/config"
  end

  def tmp_path
    "#{root_path}/tmp"
  end

  def pid_path
    "#{Dir.pwd}/tmp/pids/nginx.pid"
  end

  def get_binding
    binding
  end
end
