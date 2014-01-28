module Skylab::GitViz

  module Test_Lib_::Mock_System

    class Fixture_Server

      class Alternate_Responders__::Shut_It_Down

        def initialize host
          @host = host
          @y = host.get_qualified_stderr_line_yielder
        end

        def invoke a
          if a.length.nonzero?
            @y << "ignoring: #{ a.inspect }"
          end
          @host.shutdown
        end
      end
    end
  end
end
