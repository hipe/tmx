module Skylab::Brazen

  module API

    class Two_Stream_Event_Expresser

      def initialize * a
        @out, @err, @expag = a
      end

      def maybe_receive_on_channel_event i_a, & ev_p
        ev = ev_p[]
        ev_ = ev.to_event
        if ev_.has_member :ok
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
        ev.express_into_under y, @expag
        ACHIEVED_
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
        ev.express_into_under y, @expag

        UNABLE_
      end

      def recv_info_event ev
        recv_neutral_event ev
      end

      def recv_neutral_event ev
        y = ::Enumerator::Yielder.new do |s|
          @err.puts s
        end
        ev.express_into_under y, @expag
        nil
      end
    end
  end
end