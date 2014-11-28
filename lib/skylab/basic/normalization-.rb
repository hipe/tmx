module Skylab::Basic

      class Normalization_

        def initialize
          @event_receiver = nil
          @event_p = nil
        end

        def normalize_via_two arg, evr  # #experiment
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
          if @event_receiver.respond_to? :receive_ev
            init_event_proc_when_evr
          else
            @event_p = @event_receiver
            @event_receiver = nil
          end ; nil
        end

        def init_event_proc_when_evr
          _EVR = @event_receiver ; @event_receiver = nil  # this is the only access
          @event_p = -> * x_a, msg_p do
            _ev = bld_ev x_a, msg_p
            _EVR.receive_ev _ev
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
          if 1 == @event_p.arity
            _ev = bld_ev x_a, any_msg_p
            @event_p[ _ev ]
          else
            @event_p[ * x_a, any_msg_p ]
          end
        end

        def bld_ev x_a, msg_p
          msg_p ||= Event_[]::Inferred_Message.to_proc
          Event_[].inline_via_iambic_and_message_proc x_a, msg_p
        end

        Event_ = -> do
          Basic_._lib.event
        end
      end

end
