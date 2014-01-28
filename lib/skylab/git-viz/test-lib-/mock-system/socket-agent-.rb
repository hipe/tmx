module Skylab::GitViz

  module Test_Lib_::Mock_System

    module Socket_Agent_

      x = $VERBOSE ; $VERBOSE = nil ; GitViz::Lib_::ZMQ[] ; $VERBOSE = x

      def self.[] cls
        cls.include self
      end

    private

      def resolve_context
        init_context ; PROCEDE_
      end

      def init_context
        @context = ::ZMQ::Context.new self.class::IO_THREADS_COUNT__ ; nil
      end

      def init_socket
        @socket = @context.socket ::ZMQ::REQ ; nil
      end

      def connect_socket
        rc = @socket.connect "tcp://localhost:#{ @port_d }"
        rc.nonzero? and self.when_failed_to_connect_socket rc  # :+#hook-out
      end

      def when_socket_bind_failure d
        emit_error_string "failed to bind to socket, got error code #{ d }"
        d  # #todo this has never been triggered or "tested", could use reporting
      end

      def send_strings s_a
        d = @socket.send_strings s_a
        0 > d and when_send_failure
      end

      def when_send_failure
        report_socket_send_failure
      end

      def report_socket_send_failure
        ec, str = error_code_and_error_string
        @y << "send failure: #{ str }" ; ec
      end

      def recv_strings buffer_a
        d = @socket.recv_strings buffer_a
        0 > d and when_recv_failure
      end

      def when_recv_failure
        report_socket_recv_failure
      end

      def report_socket_recv_failure
        ec, str = error_code_and_error_string
        @y << "receive failure: #{ str }" ; ec
      end

      def error_code_and_error_string
        d = ::ZMQ::Util.errno
        [ d, ::LibZMQ.zmq_strerror( d ).read_string ]
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

      def when_failed_to_terminate_context d
        emit_error_string "failed to terminate context. (error code #{ d })"
        d  # #todo - the above has never been triggered or "tested" (reporting?)
      end

      def when_ZMQ_error
        d = ::ZMQ::Util.errno
        emit_error_string say_ZMQ_error d
        d
      end

      def say_ZMQ_error d
        s  =  ::LibZMQ.zmq_strerror( d ).read_string
        m_i = :"say_ZMQ_error_#{ result_code_to_s d }"
        if self.class.private_method_defined? m_i
          send m_i, s
        else
          "sorry, got ZMQ error code #{ d } (#{ s })"
        end
      end

      def result_code_to_s d
        0 > d and begin negative = :negative_ ; d = d.abs end
        "#{ negative }#{ d }"
      end

      def say_ZMQ_error_92 s
        "ZMQ error 92 - #{ s } (this happens when there are no arguments)"
      end
    end
  end
end
