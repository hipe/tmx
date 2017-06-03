module Skylab::Basic

  class StateMachine

    class PassiveSession___

      # the idea of a "passive session" is that rather than the parsing
      # algorithm driving the whole parse until input is exhausted, a
      # passive parse allows the user to draw one "page" at a time, and
      # input is drawn from only on-demand.

      # the "grammar" (the state machine) must be written specially for
      # this purpose - it must call a special directive to "paginate"
      # (to indicate the break between significant items).

      # aspects of this API are in "SHOUTCASE" while this is considered
      # experimental :[#044.A].

      # ==

        def initialize active_session
          @_ = active_session
          @_.downstream || @_.reinit_downstream
          @_.init_state
          @_step = :__first_step_ever
        end

        def gets
          begin
            _keep_parsing = send @_step
            # (having the variable as a symbol can be useful for debugging here.)
            _keep_parsing ? redo : break
          end while above
          remove_instance_variable :@_page_result
        end

        def __first_step_ever

          # on the first step ever, we step just like we do in an active parse
          remove_instance_variable :@_step
          x = @_.step

          # a subsequent step for a first page is like a subsequent step
          # for any page, but we make it special so it's easier to follow

          # on a subsequent step for the same page..
          @_step = :_nonfirst_step_of_any_page
          x
        end

        def _nonfirst_step_of_any_page

          # a nonfirst step for any page is just like a step in an active parse

          # (but note the handler for the state that is found here might paginate)
          _x = @_.step
          _x  # hi. #todo
        end

        # ~ (guys that set the page result:

        def immediate_notification_for_turn_page_over

          # from the "immediate notification" you cannot stop the parse
          # (for example) because this call corresponds exactly to the user
          # calling the proxy exposure, and for pragmatic reasons the result
          # to such a call should be meaningless: typically the user will
          # want to do more work in her handler after calling this exposure;
          # specifically, she will want to process the matchdata of the
          # current token by putting it into the "downstream" created
          # below. but see the next method..

          @_page_result = @_.release_downstream.finish_when_paginated
          @_.reinit_downstream
          @_step = :__STEP_IS_LOCKED_DURING_PAGE_TURNOVER   # sanity
          NIL
        end

        def step_at_end o
          if o.had_a_trueish_result
            @_.fail_because_end_and_result
          elsif @_.state.has_at_least_one_formal_transition
            @_.fail_because_end_and_transitions
          else
            @_page_result = @_.release_downstream
            remove_instance_variable :@_
            @_step = :__the_empty_step
            STOP_PARSING_
          end
        end

        def __the_empty_step
          # moving parts here or we can't have a static `gets` method
          @_page_result = NOTHING_
          STOP_PARSING_
        end

        # ~ )

        def step_after_turn_page_over o

          # unlike the previous method which handled the immediate moment
          # the user called the proxy exposure, this method is for deciding
          # what this "step" should result in..

          if o.had_a_trueish_result
            __fail_because_trueish_result o
          else
            @_step = :__first_step_of_nonfirst_page
            STOP_PARSING_
          end
        end

        def __first_step_of_nonfirst_page

          # the first step of a nonfirst page is the weird one - we want to
          # skip the call to the handler of the current state because that
          # is the one that triggerd the page turnover and we already
          # processed the matchdata from that. this arrangement might change
          # but we are trying to avoid requiring the grammar to supply a lot
          # of extra nodes to accomodate pagination. (and also we are holding
          # of on introducing new meta-grammar for pagination, beyond just
          # the dedicated directive..)

          if @_.state.has_at_least_one_formal_transition
            @_step = :_nonfirst_step_of_any_page
            @_.step_via_find_transition
          else
            __fail_because_first_state_of_nonfirst_page_had_no_transitions
          end
        end

        # -- fails

        def __fail_because_first_state_of_nonfirst_page_had_no_transitions
          _fail_because do |y|
            y << "first state of nonfirst page ({{state}}) had no transitions"
          end
        end

        def __fail_because_trueish_result o
          x = o.trueish_result
          _fail_because do |y|
            y << "for now we haven't needed to process a result resulted"
            y << "by a state ({{ state }} resulted in #{ x.inspect })"
            y << "but this could be arranged with coverage.."
          end
        end

        define_method :_fail_because, DEFINITION_FOR_THE_METHOD_CALLED_FAIL_BECAUSE_

        def state  # for messages
          @_.state
        end

      # -

      # ==

      # ==
    end
  end
end
# #history: the general idea was in a non-covered code sketch 1 or 2 commits back
