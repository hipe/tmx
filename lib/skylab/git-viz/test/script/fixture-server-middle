#!/usr/bin/env ruby -w

require_relative '../../core'

module Skylab::GitViz

  GitViz::Lib_::ZMQ[]

  exit class Test::Script::Fixture_Server_Middle

    Fixture_Server_Middle = self

    class Fixture_Server_Middle  # read [#018]:#introduction-to-the-middle-end

      def initialize port_d
        @buffer_a = []
        @port_d = port_d
        @y = ::Enumerator::Yielder.new( & $stderr.method( :puts ) )
      end

      def run
        ec = init_responder
        ec ||= resolve_context
        ec ||= resolve_and_bind_socket
        ec || trap_interrupt
        ec || run_loop
      end

    private

      def init_responder
        @responder = GitViz::Test_Lib_::Mock_System::Manifest.new @y ; nil
      end

      def resolve_context
        @context = ::ZMQ::Context.new 1 ; nil
      end

      def resolve_and_bind_socket
        @socket = @context.socket ::ZMQ::REP
        @socket.bind "tcp://*:#{ @port_d }" ; nil
      end

      def trap_interrupt
        trap "INT" do
          @y << "received shutdown signal. shutting down now."
          @socket.close
          @context.terminate
          @is_running = false
        end ; nil
      end

      def run_loop
        @result_code = SUCCESS_ ; @is_running = true
        @y << "fixture server listening on port #{ @port_d }"
        exec_loop_body while @is_running
        @result_code
      end

      def exec_loop_body
        @socket.recv_strings @buffer_a
        @is_running and process_received_strings ; nil
      end

      def process_received_strings
        response = @responder.process_strings @buffer_a
        @buffer_a.clear
        s_a = response.flatten_via_flush
        response_notify s_a
        @socket.send_strings s_a ; nil
      end

      def response_notify s_a
        buffer_a = [] ; d = -1
        last = s_a.length - 1 ; length = 0 ; limit = 444
        while true
          d < last or break( last_reached = true )
          str = s_a.fetch( d += 1 ).inspect
          next_length = length + 2 + str.length  # ', '.length
          case next_length <=> limit
          when -1 ; buffer_a << str
          when  0 ; buffer_a << str ; break
          when  1 ; limit_reached = true ; break
          end
          length = next_length
        end
        s = "#{ buffer_a * ', ' }#{ '[..]' if ! last_reached && limit_reached }"
        @y << "sending back an array of #{ last + 1 } string(s): [#{ s }]"
      end

      GENERAL_ERROR_ = 3 ; SUCCESS_ = 0
    end

    self
  end.new( 5555 ).run
end
