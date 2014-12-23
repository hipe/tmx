module Skylab::Brazen

  module API

    class Produce_bound_call__

      Callback_::Actor.call self, :properties,
        :x_a,
        :p,
        :kernel,
        :mod

      def execute

        @bound = nil  # there is no parent bound action to start

        if @p
          @p[ self ]
        end

        @st = Callback_::Iambic_Stream.via_array @x_a

        if :on_event_selectively == @x_a[ -2 ]  # :+[#049] case study: ordering hacks
          @on_event_selectively = @x_a.last
          @st.x_a_length -= 2
        else
          @on_event_selectively = __prdc_some_handle_event_selectively
        end

        _ok = resolve_bound_action
        _ok && via_bound_action_resolve_bound_call

        @bound_call
      end

    private

      def resolve_bound_action
        if @st.unparsed_exists
          via_current_tokens_resolve_action
        else
          whine_about_how_there_is_an_empty_iambic_arglist
        end
      end

      def whine_about_how_there_is_an_empty_iambic_arglist
        end_in_error_with :no_such_action, :action_name, nil
      end

      def via_current_tokens_resolve_action

        @current_unbound_action_stream = @kernel.to_unbound_action_stream

        begin

          ok = via_current_branch_resolve_action

          ok or break

          @st.advance_one

          if ! @bound.class.is_branch  # ick / meh
            break
          end

          if @st.has_no_more_content
            when_name_is_too_short
            ok = false
            break
          end

          @current_unbound_action_stream = @bound.class.to_lower_unbound_action_stream

          redo
        end while nil
        ok
      end

      def via_current_branch_resolve_action

        st = @current_unbound_action_stream
        sym = @st.current_token

        begin

          unb = st.gets
          unb or break

          if sym == unb.name_function.as_lowercase_with_underscores_symbol
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
          when_no_action_at_this_step
        end
      end

      def when_no_action_at_this_step
        end_in_error_with :no_such_action, :action_name, @st.current_token
      end

      def when_name_is_too_short
        end_in_error_with :action_name_ends_on_branch_node,
          :local_node_name, @bound.name.as_lowercase_with_underscores_symbol
      end

      def via_bound_action_resolve_bound_call

        x = @bound.bound_call_against_iambic_stream @st
        if x
          @bound_call = x
          OK_
        else
          @bound_call = x
        end
      end

      def end_in_error_with * x_a

        _result = @on_event_selectively.call :error, * x_a

        @bound_call = Brazen_.bound_call.via_value _result

        UNABLE_
      end

      def __prdc_some_handle_event_selectively

        _two_streams = Lib_::Two_streams[]

        _expag = @mod::API.expression_agent_class.new @kernel

        event_expressor = Produce_bound_call__::Two_Stream_Event_Expressor.
          new( * _two_streams, _expag )

        -> * i_a, & ev_p do

          _ev = if ev_p
            ev_p[]
          else
            Brazen_.event.inline_via_normal_extended_mutable_channel i_a
          end

          event_expressor.receive_ev _ev
        end
      end
    end
  end
end
