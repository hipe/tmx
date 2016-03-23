module Skylab::Zerk

  class Invocation_::Build_state___

    # (thoughts at [#013])

    def initialize node, findex, stack=nil, xxx

      @_xxx = xxx
      @_frame_index = findex
      @_node = node
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

        @_asc = @_node.association
        kn = @_frame_index.frame_.reader__.read_value @_asc

        _is_missing_required = if kn.is_effectively_known  # if it is set and not nil
          Require_field_library_[]
          if Fields_::Takes_many_arguments[ @_asc ]
            if kn.value_x.length.zero?  # if it is the empty array
              true
            end
          end
        else
          true  # it is nil or not set
        end

        if _is_missing_required
          ___build_entry_for_missing_required_component
        else
          Entry_for_Effectively_Known___.new kn
        end
      end

      def ___build_entry_for_missing_required_component

        nf = @_asc.name

        _unava_p = -> do
          _ev_p = -> y do
            y << "required component not present: #{ nm nf }"
          end
          [ :error, :expression, :required_component_not_present, _ev_p ]
        end

        Entry_for_Effectively_Unknown___.new _unava_p, @_asc
      end
    end

    module For_Operation___

      # models are cold [#ac-006]. readers (which need merely to produce
      # a "no" or a "yes-and-value") are then cold too. but to implement
      # [#ac-027] zerk-like operations, the act of "reading values" can
      # potentially involve executing operations which requires hotness.

      def execute

        @_fo = @_node.formal
        p = @_fo.unavailability_proc
        if p
          unava_p = p[ @_fo ]
        end

        if unava_p
          self._COVER_AND_RETROFIT
          Entry_for_Net_Unavailable_Formal_Operation___
        else
          ___recurse
        end
      end

      def ___recurse

        o = @_xxx.begin_recursion__ @_fo

        x = nil

        once = -> i_a, & ev_p do
          i_a.push ev_p
          x = i_a
        end

        o.on_unavailable_ = -> * i_a, & ev_p do
          once[ i_a, & ev_p ] ; UNRELIABLE_
        end

        bc = o.execute
        if bc
          self._OMG_WAT_FUN_you_get_to_execute_the_operation
        else
          x or self._SANITY

          # you do not emit anything now. this is being cached as a frozen
          # snapshot of this operation having been unavailable.

          self._K
          Entry_for_Net_Unavailable_Formal_Operation___.new x, x.pop, @_fo
        end
      end
    end

    # --

    class Bruh__
      def in_progress
        false
      end
    end

    class Entry_for_Net_Unavailable_Formal_Operation___ < Bruh__

      def initialize i_a, ev_p, fo

        @_NOT_YET_USED_fo = fo

        @unava_p_ = -> do
          [ * i_a, ev_p ]
        end
      end

      attr_reader(
        :unava_p_,
      )

      def cached_evaluation_
        Callback_::KNOWN_UNKNOWN
      end
    end

    class Entry_for_Available_Formal_Operation__ < Bruh__

      def initialize fo
        @_formal = fo
      end
    end

    class Entry_for_Effectively_Unknown___ < Bruh__

      def initialize unava_p, asc
        @_asc = asc
        @unava_p_ = unava_p
      end

      attr_reader(
        :unava_p_,
      )

      def cached_evaluation_
        Callback_::KNOWN_UNKNOWN
      end
    end

    class Entry_for_Effectively_Known___ < Bruh__

      def initialize evl
        @cached_evaluation_ = evl
      end

      attr_reader(
        :cached_evaluation_,
      )
    end
  end
end
