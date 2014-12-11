module Skylab::Brazen

  module API

    class Produce_bound_call__

      Callback_::Actor[ self, :properties,
        :x_a,
        :p,
        :kernel,
        :mod ]

      def execute
        prepare_ivars
        ok = resolve_action
        ok && via_action_resolve_bound_call
        @bound_call
      end

    private

      def prepare_ivars
        @action = nil
        @p and @p[ self ]
        if :on_event_selectively == @x_a[ -2 ]  # :+[#049] case study: ordering hacks
          @on_event_selectively = @x_a.last
          @x_a[ -2, 2 ] = EMPTY_A_
        else
          @on_event_selectively = nil
        end
        @d = 0 ; @x_a_length = @x_a.length
        nil
      end

      def resolve_action
        if has_more_tokens
          via_current_tokens_resolve_action
        else
          whine_about_how_there_is_an_empty_iambic_arglist
        end
      end

      def whine_about_how_there_is_an_empty_iambic_arglist
        end_in_error_with :no_such_action, :action_name, nil
      end

      def via_current_tokens_resolve_action
        @current_unbound_action_scan = @kernel.get_unbound_action_scan
        begin
          ok = via_current_branch_resolve_action
          ok or break
          advance_one
          @action.is_branch or break
          if ! has_more_tokens
            when_name_is_too_short
            ok = false
            break
          end
          @current_unbound_action_scan = @action.class.get_unbound_lower_action_scan
          redo
        end while nil
        ok
      end

      def via_current_branch_resolve_action
        scn = @current_unbound_action_scan
        i = current_token
        while cls = scn.gets
          i == cls.name_function.as_lowercase_with_underscores_symbol and break
        end
        if cls
          action = @action
          @action = cls.new @kernel
          action and @action.accept_parent_node action
          OK_
        else
          when_no_action_at_this_step
        end
      end

      def when_no_action_at_this_step
        end_in_error_with :no_such_action, :action_name, current_token
      end

      def when_name_is_too_short
        end_in_error_with :action_name_ends_on_branch_node,
          :local_node_name, @action.name.as_lowercase_with_underscores_symbol
      end

      def via_action_resolve_bound_call
        _oes_p = @on_event_selectively || prdc_some_handle_event_selectively
        x_a = @x_a[ @d .. -1 ]
        x = @action.bound_call_via_call x_a, & _oes_p
        if x
          @bound_call = x
          OK_
        else
          @bound_call = x
        end
      end

      def has_more_tokens
        @d != @x_a_length
      end

      def current_token
        @x_a.fetch @d
      end

      def advance_one
        @d += 1
      end

      def end_in_error_with * x_a
        _oes_p = @on_event_selectively || prdc_some_handle_event_selectively
        _result = _oes_p.call :error, * x_a
        @bound_call = Brazen_.bound_call.via_value _result
        UNABLE_
      end

      def prdc_some_handle_event_selectively

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
