module Skylab::Zerk

  class Index

    # for all 3 targeted modalities at writing (API, niCLI and iCLI), for
    # those interface graphs that have interdependent (that is, not fully
    # autonomous) nodes, they need to do traversals to determine their
    # availabilty and to assemble their arguments. this facilitates the
    # traversal and experiments with the caching of same. (very near [#ac-027])

    def initialize acs, parent_index=nil

      @_rdr = -> do
        x = ACS_::ReaderWriter.for_componentesque acs
        @_rdr = -> { x }
        x
      end

      @reader_proc = -> { self }  # because we provide •here

      @unavailability_proc = -> asq do
        _state = __for_assembly_touch_formal asq
        _state._cached_unavailability_proc
      end

      @_next = parent_index

      @_cache = {}
    end

    attr_reader(
      :reader_proc,
      :unavailability_proc,
    )

    # -- only as value reader (b.c :here)

    def to_hot_reader__ & oes_p
      Hot_Reader___.new self, & oes_p
    end

    # --

    def parent_frame
      @_next
    end

    # --

    def __for_assembly_touch_formal fo

      k = fo.name_symbol

      if @_cache[ k ]
        self._CRAY_fun
      end

      @_cache[ k ] = :_CIRCULAR_

      entry = __build_entry_for_op_as_requested fo

      @_cache[ k ] = entry

      entry
    end

    def __build_entry_for_op_as_requested fo

      # in the formal operation's definition it has requested that we do
      # the work of determining if the operation is available..

      _pz = fo.reifier.moduleish::PARAMETERS
      _st = _pz.to_required_symbol_stream

      unava_p_a = _accumulate_unavailabilities _st

      if unava_p_a
        Entry_for_Net_Unavailable_Formal_Operation___.new unava_p_a, fo
      else
        Entry_for_Available_Formal_Operation__.new fo
      end
    end

    def unavailability_by_stated_dependency asc, * sym_a

      # we can't cache anything for the asc itself because part of the
      # cache's key would need to be all the argument symbols too..

      _st = Callback_::Stream.via_nonsparse_array sym_a
      unava_p_a = _accumulate_unavailabilities _st
      if unava_p_a
        Here_::When_multiple_unavailabilities___[ unava_p_a, asc ]
      end
    end

    def _accumulate_unavailabilities st

      unava_p_a = nil
      begin
        sym = st.gets
        sym or break
        _state = _cached_state sym
        unava_p = _state._cached_unavailability_proc
        if unava_p
          ( unava_p_a ||= [] ).push unava_p
        end
        redo
      end while nil
      unava_p_a
    end

    def __build_and_cache_entry_for_op_from_the_outside fo

      # when (for example) an op "requires" another op, we need to defer
      # to that other op's own representation of whether or not it is
      # available, rather than just recursing to the above here and now.

      unava = fo.unavailability
      entry = if unava
        self._NEAT
      else
        Entry_for_Available_Formal_Operation__.new fo
      end
      @_cache[ fo.name_symbol ] = entry
      entry
    end

    def _cached_state k

      had = true
      x = @_cache.fetch k do
        @_cache[ k ] = :_CIRCULAR_2_
        had = false
      end
      if had
        x
      else
        ___maybe_build_and_cache_entry_for k
      end
    end

    def ___maybe_build_and_cache_entry_for k

      rdr = @_rdr[]
      asc = rdr.read_association k
      if asc
        __build_and_cache_entry_for_association asc
      else

        fo_p = rdr.read_formal_operation k
        if fo_p
          _nf = Callback_::Name.via_variegated_symbol k
          _fo = fo_p[ [ rdr, _nf ] ]
          __build_and_cache_entry_for_op_from_the_outside _fo
        else
          ___maybe_build_and_cache_by_looking_upwards k
        end
      end
    end

    def ___maybe_build_and_cache_by_looking_upwards k

      if @_next

        state = @_next._cached_state k
        state or self._SANITY

        # NOTE - we're gonna cache these here now in addition to the
        # presumable caching that the parent index does. when the time comes
        # to #stale-the-cache near #milestone-7, then it's more to have to
        # stale..

        @_cache[ k ] = state
        state
      else
        self._COVER_ME_association_not_found_anywhere_upwards
      end
    end

    def __build_and_cache_entry_for_association asc

      # assume the association represents a required component (for someone).
      # for determining any unavailability of the might-be component, we
      # first check if the association signals that the component is
      # unavailable. otherwise (and it's available), we use the knownness and
      # any known value of the component to determine unavailability - for a
      # component to be available it must be set and not nil.

      unava_p = asc.unavailability

      entry = if unava_p
        self._FUN_AND_EASY
        Entry_for_Unavailable___.new unava_p
      else

        _rdr = @_rdr[]
        kn = _rdr.read_value asc

        if kn.is_effectively_known
          Require_field_library_[]
          if Fields_::Takes_many_arguments[ asc ]
            if kn.value_x.length.zero?
              effectively_unknown = true
            end
          end
        else
          effectively_unknown = true
        end

        if effectively_unknown
          ___build_entry_for_missing_required_component asc
        else
          Entry_for_Effectively_Known___.new kn
        end
      end
      @_cache[ asc.name_symbol ] = entry
      entry
    end

    def ___build_entry_for_missing_required_component asc

      nf = asc.name

      _unava_p = -> do
        _ev_p = -> y do
          y << "required component not present: #{ nm nf }"
        end
        [ :error, :expression, :required_component_not_present, _ev_p ]
      end

      Entry_for_Effectively_Unknown___.new _unava_p, asc
    end

    class Entry_for_Net_Unavailable_Formal_Operation___

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

    class Entry_for_Available_Formal_Operation__

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

    class Entry_for_Effectively_Unknown___

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

    class Entry_for_Effectively_Known___

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

      def initialize idx, & oes_p
        @_index = idx
        @_oes_p = oes_p
      end

      def read_value_via_symbol__ sym # result must be a knownness

        # here's a move we don't dare attempt in the reader/writer..

        entry = @_index._cached_state sym
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
          rslt = deliv.deliver
          send :"__knownness_when__#{ rslt.delivery_status }__", rslt
        else
          self._NEVER_HAPPENED_BEFORE_but_OK
          Callback_::KNOWN_UNKNOWN
        end
      end

      def __knownness_when__delivery_succeeded__ rslt
        Callback_::Known_Known[ rslt.delivery_value ]
      end
    end

    Require_ACS_[]

    Here_ = self
  end
end
