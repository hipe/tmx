module Skylab::Brazen

  module API

    class Produce_bound_call__

    class Two_Stream_Event_Expressor

      def initialize * a
        @out, @err, @expag = a
      end

      def receive_ev ev
        ev_ = ev.to_event
        if ev_.has_tag :ok
          if ev_.ok
            recv_success_event ev
          elsif ev_.ok.nil?
            recv_neutral_event ev
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

        if ev.respond_to? :inflected_verb
          n_s = ev.inflected_noun
          v_s = ev.inflected_verb
          a = [ n_s, v_s ]
          a.compact!
          if a.length.nonzero?
            _to = " to \"#{ a * SPACE_ }\""
          end
        end

        y = ::Enumerator::Yielder.new do |s|
          @err.puts "API call#{ _to } failed: #{ s }"
        end
        ev.render_all_lines_into_under y, @expag

        UNABLE_
      end

      def recv_info_event ev
        recv_neutral_event ev
      end

      def recv_neutral_event ev
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
