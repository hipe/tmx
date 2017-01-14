module Skylab::Basic

  class StateMachine  # :[044] (justification at document)

    class HandlerInvocation_via_Session_

      # isolated ivarspace for each time a handler is called

      def initialize umd, sta, sess
        @user_matchdata = umd
        @__state = sta
        @_session = sess
      end

      def execute
        Outcome___.new do |o|
          @_outcome = o
          x = remove_instance_variable( :@__state ).
            next_symbol_via_exposures_proxy___ self
          if x
            o.had_a_trueish_result = true
            o.trueish_result = x
          end
        end
      end

      def TURN_PAGE_OVER  # shoutcase while [#044.A]
        @_session.immediate_notification_for_turn_page_over__
        @_outcome._mutex :_turn_page_over_
      end

      def send_any_previous_and_reinit_downstream
        @_session.send_any_previous_and_reinit_downstream__ ; nil
      end

      def send_downstream
        @_session.send_downstream__ ; nil
      end

      def reinit_downstream
        @_session.reinit_downstream ; nil
      end

      def receive_end_of_solution_when_paginated
        @_outcome._mutex :_end_when_paginated_
      end

      def receive_end_of_solution
        @_outcome._mutex :_end_
      end

      def downstream
        @_session.downstream
      end

      attr_reader(
        :user_matchdata,
      )

      # ==

      class Outcome___

        def initialize
          @_mutex_because_you_can_only_receive_one_directive = true
          yield self
          freeze
        end

        def _mutex sym
          remove_instance_variable :@_mutex_because_you_can_only_receive_one_directive
          @set_a_directive = true
          @directive_symbol = sym ; nil
        end

        attr_accessor(
          :had_a_trueish_result,
          :trueish_result,
        )

        attr_reader(
          :directive_symbol,
          :set_a_directive,
        )
      end

      # ==
    end
  end
end
# #history: abstracted from core
