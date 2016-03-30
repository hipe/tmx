module Skylab::Zerk

  class Invocation_::Build_state___

    # [#013] has an introduction to why & how we cache graph node solutions

    def initialize node, findex, stack=nil, x_o

      @_frame_index = findex
      @_node = node
      @__recurser = x_o
      @_trace_stack = [ * stack, node.name_symbol ]
    end

    def execute
      send @_node.category
      particular_execute_
    end

    def begin_session__
      send @_node.category
      __particular_begin_customizable_session
    end

  private

     def association
       extend For_Association___
     end

     def operation
       extend For_Operation___
     end

  public

    def in_progress
      true
    end

    module For_Association___

      def particular_execute_

        # if we are at this point (and the association is being evaluated),
        # assume some operation's "stated" set refers to it. it is only at
        # this (late) point that we will confirm that it is the right shape
        # (if there is such a thing) to be an association that is depended
        # upon for the purposes of sharing.

        @_asc = @_node.association
        send @_asc.model_classifications.category_symbol
      end

      def primitivesque
        __atomesque
      end

      def entitesque
        self._COVER_ME_should_be_fine_just_follow_this
        __atomesque
      end

      def compound
        self._READ_THIS  # this is the wrong way for an operation to reach
        # a compound node. the set of all compound nodes available to an
        # operation is exactly its selection stack..
      end

      def __atomesque

        # here's how we evaluate such an association: simply determine if
        # it's effectively known or not based solely on its value knownness
        # in The Store plus the smarts we add here about list-based nodes.

        kn = @_frame_index.frame_.for_invocation_read_atomesque_value_ @_asc

        # we add an extra detail to determine knownness - if it is a list-
        # type field and its array is zero length, downgrade it so it
        # appears as known unknown at normalization algorithms..

        if kn.is_effectively_known  # if it is set and not nil
          Require_field_library_[]
          if Field_::Takes_many_arguments[ @_asc ]
            if kn.value_x.length.zero?
              kn = Callback_::KNOWN_UNKNOWN
            end
          end
        end

        State__.new kn
      end
    end

    module For_Operation___

      def particular_execute_

        # if we are here than this is a dependency operation being evaluated
        # for one particular depender operation (of possibly several).
        #
        # whether it succeeds or fails, this evalution will be cached for
        # reuse by other nodes in this whole full-stack execution.

        unava_p = _unavailability_proc

        if unava_p
          self._COVER_AND_RETROFIT
          State_of_Net_Unavailable_Formal_Operation___
        else
          ___recurse
        end
      end

      def __particular_begin_customizable_session

        unava_p = _unavailability_proc
        if unava_p
          self._WEE
        else

          _o = _begin_recursion
          _o.begin_customizable_session__
        end
      end

      def ___recurse

        # (might be knkn, might be knuk. both ways are covered.)

        # (the rest of this is near [#027]#C3)
        _o = _begin_recursion
        _kn = _o.evaluate_recursion__
        State__.new _kn
      end

      def _unavailability_proc

        @_fo = @_node.formal
        p = @_fo.unavailability_proc
        if p
          p[ @_fo ]
        end
      end

      def _begin_recursion

        @__recurser.begin_recursion__ @_fo
      end
    end

    class State__  # as described in [#030]

      def initialize evl

        # (in our experience, there should be no need to add the assocation
        # to the construction or constituency of this class because the evl
        # is a known unknown that has a reason object array each of whose
        # reason has a proc to build an event which has the selection stack
        # already in it whew!)

        @__cached_evl = evl
      end

      def cached_evaluation_
        @__cached_evl
      end

      def in_progress
        false
      end
    end
  end
end
