module Skylab::Basic

  class StateMachine  # :[044] (justification at document)

    class HandlerInvocation_via_Session_

      # isolated ivarspace for each time a handler is called

      def initialize umd, sta, ds
        @downstream = ds
        @user_matchdata = umd
        @state = sta
      end

      def execute
        @_mutex_because_you_can_only_receive_one_directive = true
        _umd = remove_instance_variable :@user_matchdata
        _sta = remove_instance_variable :@state
        x = _sta.__next_symbol_via_machine_and_user_matchata self, _umd
        if x
          @had_a_trueish_result = true
          @trueish_result = x
        end
        freeze
      end

      def receive_end_of_solution
        _mutex :_end_
      end

      def _mutex sym
        remove_instance_variable :@_mutex_because_you_can_only_receive_one_directive
        @set_a_directive = true
        @directive_symbol = sym ; nil
      end

      attr_reader(
        :downstream,
        :directive_symbol,
        :had_a_trueish_result,
        :set_a_directive,
        :trueish_result,
      )
    end
  end
end
# #history: abstracted from core
