require 'guard/compat/plugin'
require 'guard/nginx/version'
require 'guard/nginx/config_processor'

module ::Guard
  class Nginx < Plugin
    def initialize(options)
      @value = "Test"
      UI.info "hello path: #{Dir.pwd}"
      Dir.mkdir("#{tmp_path}/config") unless Dir.exist?("#{tmp_path}/config")
      super
    end

    def start
      # ensure config - create tmp file
      UI.info "Starting Nginx on port #{port}"
      generate_config

      IO.popen("#{executable} -c #{tmp_path}/config/nginx.conf", 'w+')
      UI.info "Nginx started" if $?.success?
    end

    def stop
      puts pid
      if pid
        UI.info "Sending TERM signal to Nginx (#{pid})"
        FileUtils.rm "#{tmp_path}/config/nginx.conf"
        Process.kill("TERM", pid)
        true
      end
    end

    def reload
      UI.info 'reload'
      if pid
        generate_config

        UI.info "Sending HUP signal to Nginx (reloading #{pid})"
        Process.kill("HUP", pid)
        true
      end
    end

    def run_all
      reload
    end

    def run_on_change(paths)
      true
    end

    private

    def pidfile_path
      options.fetch(:pidfile) {
        File.expand_path('tmp/pids/nginx.pid', Dir.pwd)
      }
    end

    def tmp_path
      File.expand_path('tmp', Dir.pwd)
    end

    def generate_config
      UI.info 'Generating Nginx Config'
      file = ERB.new(
        File.read(
          File.expand_path('nginx/templates/nginx_config.erb', File.dirname(__FILE__))
        ),
        nil,
        '-'
      ).result(
        ConfigProcessor.new({
          port: port,
          use_ssl: true,
          http_port: 3000,
          https_port: 3001,
          server_name: 'localhost'
        }).get_binding
      )

      File.open("#{tmp_path}/config/nginx.conf", "w") { |f| f.write(file) }
    end

    def pid
      File.exist?(pidfile_path) && File.read(pidfile_path).to_i
    end

    def executable
      options.fetch(:executable) { 'nginx' }
    end

    def port
      options.fetch(:port){ 3000 }
    end
  end
end
