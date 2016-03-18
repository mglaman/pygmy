require_relative 'docker_service'

module Dory
  class Proxy
    extend Dory::DockerService

    def self.dinghy_http_proxy_image_name
      'codekitchen/dinghy-http-proxy:2.0.3'
    end

    def self.container_name
      Dory::Config.settings[:dory][:nginx_proxy][:container_name]
    end

    def self.certs_arg
      certs_dir = Dory::Config.settings[:dory][:nginx_proxy][:ssl_certs_dir]
      if certs_dir && !certs_dir.empty?
        "-p 443:443 -v #{certs_dir}:/etc/nginx/certs"
      else
        ''
      end
    end

    def self.run_cmd
      "docker run -d -p 80:80 #{self.certs_arg} "\
        "-v /var/run/docker.sock:/tmp/docker.sock -e " \
        "'CONTAINER_NAME=#{Shellwords.escape(self.container_name)}' --name " \
        "'#{Shellwords.escape(self.container_name)}' " \
        "#{Shellwords.escape(dinghy_http_proxy_image_name)}"
    end

    def self.start_cmd
      "docker start #{Shellwords.escape(self.container_name)}"
    end
  end
end
