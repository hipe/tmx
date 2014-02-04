module Skylab::Headless::TestSupport::Plugin

  class Mandango

    class Plugins__::Zerf
      def initialize x
        @host = x
      end

      def on_zwagolio
        @host.send( :up ).ohai
      end
    end
  end
end
