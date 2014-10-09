module Skylab::Brazen

  class Model_

    module Entity

      class Normalizer_

        def initialize
          @event_receiver = nil
          @event_p = nil
        end

        def via_two arg, evr  # #experiment
          normalize_via_three arg, IDENTITY_, evr
        end

      private

        def normalize_self
          if @event_receiver
            init_event_proc
          end
          nil
        end

        def init_event_proc
          if @event_receiver.respond_to? :receive_event
            init_event_proc_when_evr
          else
            @event_p = @event_receiver
            @event_receiver = nil
          end ; nil
        end

        def init_event_proc_when_evr
          _EVR = @event_receiver ; @event_receiver = nil  # this is the only access
          @event_p = -> * x_a, msg_p do
            msg_p ||= Event_[]::Inferred_Message.to_proc
            _ev = Event_[].inline_via_iambic_and_message_proc x_a, msg_p
            _EVR.receive_event _ev
          end ; nil
        end

        def send_not_OK_event_with * x_a, any_msg_p
          send_not_OK_event_with_mutable_iambic_and_any_msg_p x_a, any_msg_p
        end

        def send_not_OK_event_with_mutable_iambic_and_any_msg_p x_a, any_msg_p=nil
          if 2 > x_a.length || :error_category != x_a[ -2 ]  # :+[#049] order-dependent hack
            x_a.push :error_category, :argument_error, :ok, false
          else
            x_a.push :ok, false
          end
          @event_p[ * x_a, any_msg_p ]
        end
      end
    end
  end
end
