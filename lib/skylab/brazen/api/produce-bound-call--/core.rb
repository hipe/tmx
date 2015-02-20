module Skylab::Brazen

  module API

    class Produce_bound_call__

      # called as an actor in one place and used as a session in another

      Callback_::Actor.call self, :properties,
        :x_a,
        :kernel,
        :mod

      class << self
        def start_via_iambic x_a, k, & oes_p
          new do
            @on_event_selectively = oes_p
            @kernel = k
            @mod = k.module
            @x_a = x_a
            _init
          end
        end
      end  # >>

      def execute
        _init
        _ok = __resolve_bound_action
        _ok && __via_bound_action_resolve_bound_call
        @bound_call
      end

      def receive_top_bound_node x
        @bound = x
        @current_unbound_action_stream = @bound.to_unbound_action_stream
        nil
      end

      attr_reader :bound, :bound_call

      def iambic_stream
        @st
      end

      def _init

        @bound = nil  # there is no parent bound action to start

        st = Callback_::Iambic_Stream.via_array @x_a

        @on_event_selectively ||= begin
          if :on_event_selectively == st.random_access_( -2 )  # :+[#049] case study: ordering hacks
            x = st.pop_
            st.reverse_advance_one_
            x
          else
            __prdc_some_handle_event_selectively
          end
        end

        @st = st
        nil
      end

      def __resolve_bound_action
        if @st.unparsed_exists
          __via_current_tokens_resolve_action
        else
          __whine_about_how_there_is_an_empty_iambic_arglist
        end
      end

      def __whine_about_how_there_is_an_empty_iambic_arglist
        _end_in_error_with :no_such_action, :action_name, nil
      end

      def __via_current_tokens_resolve_action

        @current_unbound_action_stream = @kernel.to_unbound_action_stream

        begin

          ok = via_current_branch_resolve_action
          ok or break

          if ! @bound.class.is_branch  # ick / meh
            break
          end

          if @st.no_unparsed_exists
            __when_name_is_too_short
            ok = false
            break
          end

          @current_unbound_action_stream = @bound.class.to_lower_unbound_action_stream

          redo
        end while nil
        ok
      end

      def via_current_branch_resolve_action
        _resolve_action_via_unbound_stream @current_unbound_action_stream
      end

      def via_current_branch_resolve_action_promotion_insensitive
        _resolve_action_via_unbound_stream @bound.class.to_intrinsic_unbound_action_stream
      end

      def _resolve_action_via_unbound_stream st

        sym = @st.current_token

        begin

          unb = st.gets
          unb or break

          if sym == unb.name_function.as_lowercase_with_underscores_symbol
            @st.advance_one
            break
          end

          redo
        end while nil

        if unb
          bnd = @bound
          @bound = unb.new @kernel, & @on_event_selectively
          if bnd
            @bound.accept_parent_node_ bnd
          end
          OK_
        else
          __when_no_action_at_this_step
        end
      end

      def __when_no_action_at_this_step
        _end_in_error_with :no_such_action, :action_name, @st.current_token
      end

      def __when_name_is_too_short
        _end_in_error_with :action_name_ends_on_branch_node,
          :local_node_name, @bound.name.as_lowercase_with_underscores_symbol
      end

      def __via_bound_action_resolve_bound_call

        x = @bound.bound_call_against_iambic_stream @st
        if x
          @bound_call = x
          OK_
        else
          @bound_call = x
        end
      end

      def _end_in_error_with * x_a

        _result = @on_event_selectively.call :error, x_a.first do
          Callback_::Event.inline_not_OK_via_mutable_iambic_and_message_proc x_a, nil
        end

        @bound_call = Brazen_.bound_call.via_value _result

        UNABLE_
      end

      def __prdc_some_handle_event_selectively

        _two_streams = LIB_.two_streams

        _expag = @mod::API.expression_agent_class.new @kernel

        event_expresser = Produce_bound_call__::Two_Stream_Event_Expresser.
          new( * _two_streams, _expag )

        -> * i_a, & ev_p do

          event_expresser.maybe_receive_on_channel_event i_a do
            if ev_p
              ev_p[]
            else
              Brazen_.event.inline_via_normal_extended_mutable_channel i_a
            end
          end
        end
      end
    end
  end
end
