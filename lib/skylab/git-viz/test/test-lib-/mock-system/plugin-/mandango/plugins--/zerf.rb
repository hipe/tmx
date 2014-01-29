module Skylab::GitViz::TestSupport::Test_Lib_::Mock_System::Plugin_

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
