module Skylab::TanMan

  module API

    class Produce_bound_call__

      Callback_::Actor[ self, :properties, :x_a, :p, :kernel, :mod ]

      TanMan_::Lib_::Event_builder[ self ]

      def execute
        prepare_ivars
        ok = resolve_action
        ok && via_action_resolve_bound_call
        @bound_call
      end

      def set_delegate x
        @delegate_x = x ; nil
      end

    private

      def prepare_ivars
        @d = 0 ; @x_a_length = @x_a.length
        @delegate_x = nil
        @p and @p[ self ]
        nil
      end

      def resolve_action
        if has_more_tokens
          via_current_tokens_resolve_action
        else
          whine_about_how_there_is_an_empty_iambic_argument_list
        end
      end

      def whine_about_how_there_is_an_empty_iambic_argument_list
        end_in_error_with :no_such_action, :action_name, nil
      end

      def via_current_tokens_resolve_action
        @current_unbound_action_scan = @kernel.get_unbound_action_scan
        while true
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
        end
        ok
      end

      def via_current_branch_resolve_action
        scn = @current_unbound_action_scan
        i = current_token
        while cls = scn.gets
          i == cls.name_function.as_lowercase_with_underscores_symbol and break
        end
        if cls
          @action = cls.new @kernel
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
        x_a = @x_a[ @d .. -1 ]
        x = @action.produce_bound_call_via_iambic_and_delegate x_a, delegate
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

      def end_in_error_with * x_a, & p
        _ev = build_error_event_via_mutable_iambic_and_message_proc x_a, p
        result = send_event _ev
        @bound_call = Brazen_.bound_call IDENTITY_, :call, result
        UNABLE_
      end

      def send_event ev
        delegate.receive_event ev
      end

      def delegate
        @delegate_x || rslv_some_delegate_x
        @delegate_x
      end

      def rslv_some_delegate_x
        _exp = API::Expression_Agent__.new @kernel
        @delegate_x = API::Two_Stream_Event_Expressor__.
          new( * TanMan_::Lib_::Two_streams[], _exp ) ; nil
      end
    end
  end
end
