module Skylab::Brazen

  # ->

    Sessions_ = ::Module.new
    class Sessions_::Produce_Bound_Call

      attr_reader(
        :bound,
        :poly_stream,
      )

      attr_writer(
        :module,
        :poly_stream,
      )

      def initialize k, & oes_p
        @bound = nil
        @kernel = k
        @on_event_selectively = oes_p
        @mutable_box = nil
      end

      def iambic= x_a

        if :on_event_selectively == x_a[ -2 ]  # :+[#049] case study: ordering hacks
          oes_p = x_a[ -1 ]
          x_a[ -2, 2 ] = EMPTY_A_
        end

        if oes_p
          @on_event_selectively = oes_p
        end

        @poly_stream = Callback_::Polymorphic_Stream.via_array x_a
        NIL_
      end

      def mutable_box= bx

        oes_p = bx.remove :on_event_selectively do end
        if oes_p
          @on_event_selectively = oes_p
        end
        @mutable_box = bx
        NIL_
      end

      def receive_top_bound_node x
        @bound = x
        @current_unbound_action_stream = @bound.to_unbound_action_stream
        NIL_
      end

      def execute  # `prouduce_bound_call` was subsumed by here

        @on_event_selectively ||= __produce_some_handle_event_selectively

        _ok = __resolve_bound_action
        _ok && __via_bound_action_produce_bound_call
      end

      def __resolve_bound_action

        if @poly_stream.unparsed_exists
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

          if ! @bound.is_branch
            break
          end

          if @poly_stream.no_unparsed_exists
            __when_name_is_too_short
            ok = false
            break
          end

          @current_unbound_action_stream = @bound.to_lower_unbound_action_stream

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

        sym = @poly_stream.current_token

        begin

          unb = st.gets
          unb or break

          if sym == unb.name_function.as_lowercase_with_underscores_symbol
            @poly_stream.advance_one
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
          ACHIEVED_
        else
          __when_no_action_at_this_step
        end
      end

      def __when_no_action_at_this_step
        _end_in_error_with :no_such_action, :action_name, @poly_stream.current_token
      end

      def __when_name_is_too_short
        _end_in_error_with :action_name_ends_on_branch_node,
          :local_node_name, @bound.name.as_lowercase_with_underscores_symbol
      end

      def __via_bound_action_produce_bound_call

        if @mutable_box

          if @poly_stream.unparsed_exists

            @bound.bound_call_against_polymorphic_stream_and_mutable_box(
              @poly_stream, @mutable_box )

          else
            @bound.bound_call_against_box @mutable_box
          end
        else
          @bound.bound_call_against_polymorphic_stream @poly_stream
        end
      end

      def _end_in_error_with * x_a

        _result = @on_event_selectively.call :error, x_a.first do
          Callback_::Event.inline_not_OK_via_mutable_iambic_and_message_proc x_a, nil
        end

        @bound_call = Callback_::Bound_Call.via_value _result

        UNABLE_
      end

      def __produce_some_handle_event_selectively

        _two_streams = LIB_.two_streams

        _expag = @module.const_get( :API, false ).expression_agent_instance

        event_expresser = Home_::API::Two_Stream_Event_Expresser.
          new( * _two_streams, _expag )

        -> * i_a, & ev_p do

          event_expresser.maybe_receive_on_channel_event i_a do
            if ev_p
              ev_p[]
            else
              Callback_::Event.inline_via_normal_extended_mutable_channel i_a
            end
          end
        end
      end
    end
    # <-
end
