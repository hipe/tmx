module Skylab::GitViz

  module Test_Lib_::Mock_System

    module Socket_Agent_

      x = $VERBOSE ; $VERBOSE = nil ; GitViz::Lib_::ZMQ[] ; $VERBOSE = x

      def self.[] cls
        cls.include self
      end

    private

      def resolve_context_and_bind_reply_socket &p
        ec = resolve_context
        ec || resolve_and_bind_reply_socket( &p )
      end

      def resolve_context_and_bind_request_socket &p
        ec = resolve_context
        ec || resolve_and_bind_request_socket( &p )
      end

      def resolve_context
        init_context ; CONTINUE_
      end

      def init_context
        @context = ::ZMQ::Context.new self.class::IO_THREADS_COUNT__ ; nil
      end

      def resolve_and_bind_reply_socket &p
        init_reply_socket ; ec = CONTINUE_
        p and p[ @socket ].nonzero? and ec = when_setsockopt_failure
        ec || connect_reply_socket
      end

      def resolve_and_bind_request_socket &p
        init_request_socket ; ec = CONTINUE_
        p and p[ @socket ].nonzero? and ec = when_setsockopt_failure
        ec || connect_request_socket
      end

      def init_reply_socket
        @socket = @context.socket ::ZMQ::REP ; nil
      end

      def init_request_socket
        @socket = @context.socket ::ZMQ::REQ ; nil
      end

      def connect_reply_socket
        rc = @socket.bind "tcp://*:#{ @port_d }"
        rc.nonzero? and when_socket_bind_failure
      end

      def when_socket_bind_failure
        ec, s = error_code_and_reason_string
        emit_error_string "failed to bind to socket #{ s }"
        ec
      end

      def connect_request_socket
        rc = @socket.connect "tcp://localhost:#{ @port_d }"
        rc.nonzero? and when_failed_to_connect_socket
      end

      def when_failed_to_connect_socket
        ec, s = error_code_and_reason_string
        emit_error_string "failed to connect to socket #{ s }"
        ec
      end

      def send_strings s_a
        d = @socket.send_strings s_a
        0 > d and when_send_failure
      end

      def when_send_failure
        report_and_result_in_socket_send_failure
      end

      def report_and_result_in_socket_send_failure
        ec, s = error_code_and_reason_string
        emit_error_string "failed to send #{ s }"
        ec
      end

      def recv_strings buffer_a
        d = @socket.recv_strings buffer_a
        0 > d and when_recv_failure
      end

      def when_recv_failure
        @buffer_a.clear  # probably a good idea
        report_and_result_in_socket_recv_failure
      end

      def report_and_result_in_socket_recv_failure
        ec, str = error_code_and_reason_string
        emit_error_string "failed to receive #{ str }"
        ec
      end

      def close_socket_and_terminate_context
        ec = close_socket
        ec || terminate_context
      end

      def close_socket
        d = @socket.close
        d.zero? or emit_error_string "failed to close connection? #{ d }"  # :+#hook-out
        d.nonzero?
      end

      def terminate_context
        d = @context.terminate
        d.nonzero? and when_failed_to_terminate_context d
      end

      def when_failed_to_terminate_context
        emit_error_string "failed to terminate context. (error code #{ d })"
        d  # #todo - the above has never been triggered or "tested" (reporting?)
      end

      def when_ZMQ_error
        ec, str = error_code_and_reason_string
        emit_error_string str
        ec
      end

      def error_code_and_reason_string
        ec = ::ZMQ::Util.errno
        [ ec, say_ZMQ_error( ec ) ]
      end

      def say_ZMQ_error d
        s  = ::LibZMQ.zmq_strerror( d ).read_string
        m_i = :"say_ZMQ_error_#{ res_code_as_method_tail d }"
        if self.class.private_method_defined? m_i
          send m_i, s
        else
          s.sub! %r(\A[A-Z]), & :downcase
          "because #{ s } (zmq error code #{ d })"
        end
      end

      def res_code_as_method_tail d
        0 > d and begin negative = :negative_ ; d = d.abs end
        "#{ negative }#{ d }"
      end

      def say_ZMQ_error_92 s
        "#{ s } (zmq code 92) (this happens when there are no arguments)"
      end
    end
  end
end
