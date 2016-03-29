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
    end

  private

     def association
       extend For_Association___
       execute
     end

     def operation
       extend For_Operation___
       execute
     end

  public

    def in_progress
      true
    end

    module For_Association___

      def execute

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

        # here's how we evaluate such association: simply determine if it's
        # effectively known or not based solely on its value knownness in
        # The Store plus the smarts we add here about list-based nodes.

        kn = @_frame_index.frame_.reader__.read_value @_asc

        # we add an extra detail to determine knownness:

        if kn.is_effectively_known  # if it is set and not nil
          Require_field_library_[]
          if Field_::Takes_many_arguments[ @_asc ]
            is_effectively_known = kn.value_x.length.nonzero?
          else
            is_effectively_known = true
          end
        end

        if is_effectively_known
          State_of_Association_with_Value_Effectively_Known___.new kn
        else
          State_of_Association_with_Value_Effectively_Unknown___.new @_asc
        end
      end
    end

    module For_Operation___

      # models are cold [#ac-006]. readers (which need merely to produce
      # a "no" or a "yes-and-value") are then cold too. but to implement
      # [#ac-027] zerk-like operations, the act of "reading values" can
      # potentially involve executing operations which requires hotness.

      def execute

        # if we are here than this is the dependency operation being
        # evaluated for a depender operation (and whether succueed or fail,
        # this evaluation will be cached for reuse by others in this whole
        # full-stack execution.)

        @_fo = @_node.formal
        p = @_fo.unavailability_proc
        if p
          unava_p = p[ @_fo ]
        end

        if unava_p
          self._COVER_AND_RETROFIT
          State_of_Net_Unavailable_Formal_Operation___
        else
          ___recurse
        end
      end

      def ___recurse

        _o = @__recurser.begin_recursion__ @_fo

        evl = _o.evaluate_recursion__

        # (the rest of this is near [#027]#"C3")

        if evl.is_known_known
          self._A
        else
          self._REVIEW
          State_of_Operation_with_Value_Effectively_Unknown___.new evl
        end
      end
    end

    class State__
      def in_progress
        false
      end
    end

    class State_of_Operation_with_Value_Effectively_Unknown___ < State__

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
    end

    class State_of_Association_with_Value_Effectively_Unknown___ < State__

      def initialize asc
        @_asc = asc
      end

      def unava_p_
        self._K
      end

      def cached_evaluation_
        Callback_::KNOWN_UNKNOWN
      end
    end

    class State_of_Association_with_Value_Effectively_Known___ < State__

      def initialize evl
        @__cached_evl = evl
      end

      def cached_evaluation_
        @__cached_evl
      end
    end
  end
end
