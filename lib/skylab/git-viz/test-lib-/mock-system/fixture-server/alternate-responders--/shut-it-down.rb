module Skylab::GitViz

  module Test_Lib_::Mock_System

    class Fixture_Server

      class Alternate_Responders__::Shut_It_Down

        # this is the implementation of a "server directive" ("alternate
        # responder" whose job it is to take a request received by the server
        # that looks like a shutdown request and reify it somehow. in any
        # case, this thing *must* result in exactly one 'send' from the
        # server.

        Mock_System::Socket_Agent_[ self ]

        def initialize host
          @context, @socket = host.context_and_socket
          @host = host ; @serr_p = host.stderr_reference
          @y = host.get_qualified_stderr_line_yielder
        end

        def invoke a
          @a = a ; @message = nil
          p = self.class.method :private_method_defined?
          while p[ m_i = :"#{ a.first }=" ]
            a.shift
            send m_i
          end
          is_valid && shut_it_down
        end

      private

        def message=
          @message = @a.shift
        end

        def is_valid
          if @a.length.nonzero?
            respond_with_error_message "unexpected arguments #{ @a.inspect }"
            false
          elsif ! @message
            respond_with_error_message "expecting 'message' <message>"
            false
          else
            true
          end
        end

        def shut_it_down
          @host.shut_down @message do |sd|
            sd.when_did_not do |msg|
              @y << "(#{ msg })"
              respond_with_error_message msg
              CONTINUE_
            end
            sd.when_did do |msg|
              @y << msg
              respond_with_info_message msg
              SILENT_
            end
            sd.info_line @y.method( :<< )
            sd.info_line_head do |s|
              @serr_p[].write s
            end
            sd.info_line_tail do |s|
              @serr_p[].puts s
            end
          end
        end

        def respond_with_error_message rsn_s
          respond_with_info_message "won't shutdown because #{ rsn_s }"
        end

        def respond_with_info_message s
          send_strings [ 'result_code', '513', 'statement', '2', 'info', s ]
          SILENT_
        end  # 5->s 1->i 3->d (qwerty proximity)  "shut it down"

        def emit_error_string s
          @y << s
        end
      end
    end
  end
end
