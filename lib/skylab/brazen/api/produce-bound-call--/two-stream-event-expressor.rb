module Skylab::Brazen

  module API

    class Produce_bound_call__

    class Two_Stream_Event_Expressor

      def initialize * a
        @out, @err, @expag = a
      end

      def receive_event ev
        if ev.has_tag :ok
          if ev.ok
            recv_success_event ev
          else
            recv_error_event ev
          end
        else
          recv_info_event ev
        end
      end

      def app_name
        @expag.app_name
      end

    private
      def recv_success_event ev
        y = ::Enumerator::Yielder.new do |s|
          @out.puts "OK: #{ s }"
        end
        ev.render_all_lines_into_under y, @expag
        OK_
      end

      def recv_error_event ev
        y = ::Enumerator::Yielder.new do |s|
          @err.puts "API call failed: #{ s }"
        end
        ev.render_all_lines_into_under y, @expag
        UNABLE_
      end

      def recv_info_event ev
        y = ::Enumerator::Yielder.new do |s|
          @err.puts s
        end
        ev.render_all_lines_into_under y, @expag
        nil
      end

    end
    end

  end
end
