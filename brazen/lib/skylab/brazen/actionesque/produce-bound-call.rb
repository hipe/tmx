module Skylab::Brazen
  # ->
    class Actionesque::Produce_Bound_Call

      attr_reader(
        :argument_stream,
        :current_bound,
      )

      attr_writer(
        :module,  # just for resolving some event handler when necessary
        :argument_stream,
        :current_bound,
        :unbound_stream,
      )

      def initialize k, & oes_p
        @current_bound = nil
        @subject_unbound = k
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

        @argument_stream = Callback_::Polymorphic_Stream.via_array x_a
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

      def execute

        @on_event_selectively ||= __produce_some_handle_event_selectively

        _ok = __resolve_bound
        _ok && __via_bound_produce_bound_call
      end

      def __resolve_bound

        if @argument_stream.unparsed_exists

          @unbound_stream = @subject_unbound.build_unordered_selection_stream(
            & @on_event_selectively )

          __parse_arugument_stream_against_unbound_stream
        else
          __whine_about_how_there_is_an_empty_iambic_arglist
        end
      end

      def __whine_about_how_there_is_an_empty_iambic_arglist
        _end_in_error_with :no_such_action, :action_name, nil
      end

      def __parse_arugument_stream_against_unbound_stream

        begin

          ok = find_via_unbound_stream
          ok or break

          if ! @current_bound.is_branch
            break
          end

          if @argument_stream.no_unparsed_exists
            __when_name_is_too_short
            ok = false
            break
          end

          @unbound_stream = @current_bound.to_unordered_selection_stream

          redo
        end while nil
        ok
      end

      def find_via_unbound_stream  # resolves current_bound. results in t/f

        st = @unbound_stream
        sym = @argument_stream.current_token

        begin

          unb = st.gets
          unb or break

          if sym == unb.name_function.as_lowercase_with_underscores_symbol
            @argument_stream.advance_one
            break
          end

          redo
        end while nil

        if unb

          bnd = @current_bound
          @current_bound = unb.new @subject_unbound, & @on_event_selectively
          if bnd
            @current_bound.accept_parent_node bnd
          end
          ACHIEVED_
        else
          __when_no_bound_at_this_step
        end
      end

      def __when_no_bound_at_this_step
        _end_in_error_with :no_such_action, :action_name, @argument_stream.current_token
      end

      def __when_name_is_too_short
        _end_in_error_with :action_name_ends_on_branch_node,
          :local_node_name, @current_bound.name.as_lowercase_with_underscores_symbol
      end

      def __via_bound_produce_bound_call

        if @mutable_box

          if @argument_stream.unparsed_exists

            @current_bound.bound_call_against_polymorphic_stream_and_mutable_box(
              @argument_stream, @mutable_box )

          else
            @current_bound.bound_call_against_box @mutable_box
          end
        else
          @current_bound.bound_call_against_polymorphic_stream @argument_stream
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
