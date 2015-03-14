module Skylab::GitViz

  module Test_Lib_::Mock_System

    class Fixture_Server

      class Alternate_Responders__::Ping

        Mock_System::Socket_Agent_[ self ]

        def initialize host
          @context, @socket = host.context_and_socket
        end

        def invoke a
          resp_a = []
          a.length.nonzero? and resp_a.concat 'statement', '2', 'info',
            "(the following ping operation will ignore #{ a.inspect })"
          resp_a.push 'statement', '2', 'info',
            "middle server says 'hello' in response to your ping"
          resp_a.push 'result_code', '0'
          send_strings resp_a
          SILENT_
        end
      end
    end
  end
end
