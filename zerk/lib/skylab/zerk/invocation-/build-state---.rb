module Skylab::Zerk

  class Index

    # for all 3 targeted modalities at writing (API, niCLI and iCLI), for
    # those interface graphs that have interdependent (that is, not fully
    # autonomous) nodes, they need to do traversals to determine their
    # availabilty and to assemble their arguments. this facilitates the
    # traversal and experiments with the caching of same. (very near [#ac-027])
    # now with better circular-dependeny checking.

    def initialize acs, parent_index=nil

      @_rdr = -> do
        x = ACS_::ReaderWriter.for_componentesque acs
        @_rdr = -> { x }
        x
      end

      @reader_proc = -> { self }  # because we provide •here

      @unavailability_proc = -> asq do
        _state = __cached_state_procedurally asq
        _state._cached_unavailability_proc
      end

      @_next = parent_index

      @_cache = {}
    end

    attr_reader(
      :reader_proc,
      :unavailability_proc,
    )

    # -- we have one method to implement b.c :here

    def to_hot_reader_for_ACS_for__ sess
      Hot_Reader___.new sess, self, & sess.handle_event_selectively_for_zerk
    end

    # --

    def parent_frame
      @_next
    end

    # --

    def unavailability_by_stated_dependency asc, * sym_a

      # we can't cache anything for the asc itself because part of the
      # cache's key would need to be all the argument symbols too..

      k = asc.name_symbol
      en = @_cache[ k ]
      if en
        self._WHAT  # this suggests we're doing it wrong
      end

      _st = Callback_::Stream.via_nonsparse_array sym_a
      unava_p_a = _accumulate_unavailabilities _st
      if unava_p_a
        Here_::When_multiple_unavailabilities___[ unava_p_a, asc ]
      end
    end

    def _accumulate_unavailabilities st

      unava_p_a = nil
      begin
        k = st.gets
        k or break
        _state = _cached_state_recursively k
        unava_p = _state._cached_unavailability_proc
        if unava_p
          ( unava_p_a ||= [] ).push unava_p
        end
        redo
      end while nil
      unava_p_a
    end

    def _cached_state_recursively k, stack=nil

      en = @_cache[k]
      if en
        if en.in_progress
          self._EEK
        else
          en
        end
      else
        asq = ___read_association_here k
        if asq
          _build_and_cache_state_for_asq_found_here asq, stack, false
        elsif @_next
          __read_and_cache_from_towards_root k, stack
        else
          self._COVER_ME_reached_root_without_finding_association
        end
      end
    end

    def ___read_association_here k

      rdr = @_rdr[]

      @_cache[ k ] = READING___
      asq = rdr.read_association k
      if ! asq
        fo_p = rdr.read_formal_operation k
        if fo_p
          _nf = Callback_::Name.via_variegated_symbol k
          asq = fo_p[ [ rdr, _nf ] ]
        end
      end
      @_cache[ k ] = nil
      asq
    end

    READING___ = :_reading_

    def __cached_state_procedurally asq
      _build_and_cache_state_for_asq_found_here asq, nil, true
    end

    def _build_and_cache_state_for_asq_found_here asq, stack, is_procedural

      k = asq.name_symbol

      bs = BUILD_STATE___.fetch( asq.associationesque_category ).new(
        asq, stack, self, is_procedural )

      @_cache[ k ] = bs
      state = bs.execute
      @_cache[ k ] = state
      state
    end

    def __read_and_cache_from_towards_root k, stack

      # NOTE - we're gonna cache these here now in addition to the
      # presumable caching that the parent index does. when the time comes
      # to #stale-the-cache near #milestone-7, then it's more to have to
      # stale..

      state = @_next._cached_state_recursively k, stack
      @_cache[ k ] = state
      state
    end

    # -- only for "build state"

    def __reader
      @_rdr[]
    end

    o = {}

    class Build_State__

      # assume that the cache is locked with us as the entry

      # the "procedurally" flag means that this request to build state
      # came at the behest of one of the callbacks in the selfsame definition
      # of the associationesque, so we should not descend into that callback
      # again.

      def initialize asq, stack, index, is_procedural

        _k = asq.name_symbol

        @_stack = if stack
          [ * stack, _k ]
        else
          [ _k ]
        end

        @_be_procecural = is_procedural
        @_index = index
      end

      def in_progress
        true
      end
    end

    o[ :association ] =
    class Build_Association_State____ < Build_State__

      def initialize( asq, * )
        super
        @_asc = asq
      end

      def execute

        # assume the association represents a required component (for someone).
        # for determining any unavailability of the might-be component, we
        # first check if the association signals that the component is
        # unavailable..

        if @_be_procecural
          self._COVER_ME_never_needed_procedural_for_assoc_before
        end

        unava_p = @_asc.unavailability
        if unava_p
          self._FUN_AND_EASY
          EG_Entry_for_Unava___.new unava_p, @_asc
        else
          ___build_state_for_available_asc
        end
      end

      def ___build_state_for_available_asc

        # ..otherwise (and it's available), we use the knownness and any known
        # value of the component to determine unavailability: for a component
        # to be available it must be set and not nil.

        kn = @_index.__reader.read_value @_asc

        _no = if kn.is_effectively_known  # if it is set and not nil
          Require_field_library_[]
          if Fields_::Takes_many_arguments[ @_asc ]
            if kn.value_x.length.zero?  # if it is the empty array
              true
            end
          end
        else
          true  # it is nil or not set
        end

        if _no
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

      self
    end

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

        unava = @_fo.unavailability
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

      def _cached_unavailability_proc
        @_my_unava_p
      end

      def _was_available
        false
      end

      def _is_formal_operation
        true
      end
    end

    class Entry_for_Available_Formal_Operation__ < Bruh__

      def initialize fo
        @_formal = fo
      end

      def _cached_unavailability_proc
        NOTHING_
      end

      attr_reader :_formal

      def _was_available
        true
      end

      def _is_formal_operation
        true
      end
    end

    class Entry_for_Effectively_Unknown___ < Bruh__

      def initialize unava_p, asc
        @_asc = asc
        @_unava_p = unava_p
      end

      def _cached_unavailability_proc
        @_unava_p
      end

      def _knownness
        Callback_::KNOWN_UNKNOWN
      end

      def _was_available
        false
      end

      def _is_formal_operation
        false
      end
    end

    class Entry_for_Effectively_Known___ < Bruh__

      def initialize kn
        @_kn = kn
      end

      def _cached_unavailability_proc
        NOTHING_
      end

      def _knownness
        @_kn
      end

      def _was_available
        true
      end

      def _is_formal_operation
        false
      end
    end

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

    Require_ACS_[]

    Here_ = self
  end
end
