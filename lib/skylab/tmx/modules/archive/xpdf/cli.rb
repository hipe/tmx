module Skylab::TMX

  module Modules::Xpdf

    class CLI < CLI_Client_[]

      set :desc, -> y do
        y << "idem."
      end

      def ping
        @y << "hello from xpdf."
        :hello_from_xpdf
      end

      # external_dependencies File.expand_path('../data/deps.json', __FILE__)

    end
  end
end
