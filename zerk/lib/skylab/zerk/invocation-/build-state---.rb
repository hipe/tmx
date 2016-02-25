module Skylab::Zerk

  class Invocation_::Build_state___

    # (thoughts at [#013])

    def initialize node, findex, stack=nil

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

    if false  # #milestone-3

    o[ :formal_operation ] =
    class Build_Formal_Operation_State____ < Build_State__

      def initialize( fo, * )
        super
        @_fo = fo
      end

      def execute
        if @_be_procecural
          __build_state_for_op_procedurally
        else
          ___build_state_for_op_autonomously
        end
      end

      def ___build_state_for_op_autonomously

        # when (for example) an op "requires" another op, we need to defer
        # to that other op's own representation of whether or not it is
        # available, rather than just recursing to the above here and now.

        unava = @_fo.determine_unavailability
        if unava
          self._NEAT
        else
          Entry_for_Available_Formal_Operation__.new @_fo
        end
      end

      def __build_state_for_op_procedurally

        # in the formal operation's definition it has requested that we do
        # the work of determining if the operation is available..

        _ = @_fo.reifier.moduleish::PARAMETERS
        _st = _.to_required_symbol_stream

        unava_p_a = @_index._accumulate_unavailabilities _st

        if unava_p_a
          Entry_for_Net_Unavailable_Formal_Operation___.new unava_p_a, @_fo
        else
          Entry_for_Available_Formal_Operation__.new @_fo
        end
      end

      self
    end

    BUILD_STATE___ = o
    end

    # --

    class Bruh__
      def in_progress
        false
      end
    end

    class Entry_for_Net_Unavailable_Formal_Operation___ < Bruh__

      def initialize unava_p_a, fo
        @_fo = fo
        if 1 == unava_p_a.length
          @_my_unava_p = unava_p_a.fetch 0
        else
          self._TONS_OF_FUN
        end
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
        @_unava_p = unava_p
      end

      def knownness_
        Callback_::KNOWN_UNKNOWN
      end
    end

    class Entry_for_Effectively_Known___ < Bruh__

      def initialize kn
        @knownness_ = kn
      end

      attr_reader(
        :knownness_,
      )
    end

    if false
    class Hot_Reader___

      # models are cold [#ac-006]. readers (which need merely to produce
      # a "no" or a "yes-and-value") are then cold too. but to implement
      # [#ac-027] zerk-like operations the act of "reading values" can
      # potentially involve executing operations, which requires hotness.

      def initialize sess, idx, & oes_p
        @_index = idx
        @_session = sess
        @_oes_p = oes_p
      end

      def read_value_via_symbol__ k  # result must be a knownness

        # here's a move we don't dare attempt in the reader/writer..

        entry = @_index._cached_state_recursively k
        if entry._is_formal_operation
          if entry._was_available
            ___read_value_of_operation entry
          else
            self._B
          end
        else
          entry._knownness
        end
      end

      def ___read_value_of_operation entry

        deliv = entry._formal.deliverable_as_is( & @_oes_p )
        if deliv

          m = :"with__#{ entry._formal.name_symbol }__"  # begin [#ac-027]#A

          if @_session.respond_to? m
            __knownness_for_customly_execute m, deliv
          else
            rslt = deliv.deliver
            send :"__knownness_when__#{ rslt.delivery_status }__", rslt
          end
        else
          self._NEVER_HAPPENED_BEFORE_but_OK
          Callback_::KNOWN_UNKNOWN
        end
      end

      def __knownness_when__delivery_succeeded__ rslt
        Callback_::Known_Known[ rslt.delivery_value ]
      end

      def __knownness_for_customly_execute m, deliv

        x = @_session.send m, deliv.bound_call.receiver
        if x
          Callback_::Known_Known[ x ]
        else
          self._ETC_easy
        end
      end
    end
    end
  end
end
