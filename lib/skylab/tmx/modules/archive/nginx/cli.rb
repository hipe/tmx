module Skylab::TMX

  module Modules::Nginx

    class CLI < CLI_Client_[]

      set :desc, -> y do
        y << "(this used to install nginx, could be resucitated)"
        y << "(off or now.)"
      end

      def ping
        @y << "hello from nginx."
        :hello_from_nginx
      end

      # external_dependencies File.expand_path('../data/deps.json', __FILE__)

    end
  end
end
