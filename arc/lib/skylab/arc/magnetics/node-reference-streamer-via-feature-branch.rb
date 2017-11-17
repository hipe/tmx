module Skylab::Arc

  class Magnetics::NodeReferenceStreamer_via_FeatureBranch

    # :[#036]

      # a "streamer" generally is a performer that produces a stream
      # (re-entrantly): it's like a proc that you can call multiple times,
      # each time producing a new same-ish stream.
      #
      # the subject streamer produces streams of what we now call
      # "node references". the "node reference":
      #
      #   • munges generally operations and components (and whatever else
      #     similar we might come up with).
      #
      #   • facilitates the delivery of both operation- and component- related
      #     values in a semi-uniform way.
      #
      #   • is an implementation of a #[#018] "loadable reference" - resolves the
      #     various implementation components of the association-or-formal
      #     lazily, as-needed.
      #
      #   • must be suitable for *all* reflection concerns (including indexing)
      #     so it won't reduce based on meta-components like availability or
      #     conceptual componets like "intent". (this is made to serve as the
      #     upstream for clients that *do* reduce in this manner.)
      #
      #   • has a name that is or isn't mutated by its definition
      #     based on whether the definition has been loaded yet EEK

      class << self

        def via_ACS acs

          # for clients (ACS or otherwise) who don't know or care about
          # holding a reader-writer themselves..

          _rw = Home_::Magnetics::FeatureBranch_via_ACS.for_componentesque acs
          ___via_reader _rw
        end

        def ___via_reader rdr
          rdr.to_node_reference_streamer
        end

        def via_reader x
          new x
        end

        private :new
      end  # >>

      def initialize rdr
        @_reader = rdr
      end

      attr_writer(
        :on_association,
        :on_operation,
      )

      # something nasty hit us in our jump from ruby version 2.2.3 to 2.4.1 -
      # no longer is the code order reflected in your calls to
      # `instance_methods( false )` on a class.
      # (of course not. why should it be?) so
      # a founding principle of [arc] is ripped out out from under us.

      # hypothetically this needn't affect everything adversely, but
      # those apps that relied on this behavior need new markup. because
      # associations are evaluated lazily, it's not easy to "peek" to
      # see if the first node defines an ordinal. this is why we use this
      # nasty constant for those classes that etc..

      # after all, thogh, perhaps it's a misfeature

      def execute

        @on_association ||= default_on_association
        @on_operation ||= default_on_operation

        st = @_reader.to_entry_stream__

        if __do_order_fix
          __execute_ordered st
        else
          __execute_unordered st
        end
      end

      def __execute_ordered en_st

        #   - sadly operations have a different API than component
        #     associations so they each need their own handling.
        #
        #   - because OCD we don't want to dereference off the same shape
        #     symbol 2x per item, so we have duplicated some logic from the
        #     non-ordered counterpart.
        #
        #   - we definitely have to flush the whole stream before we can
        #     sort it. this is not like the linked list lazy stream sorting
        #     we do elsewhere

        a = []
        begin
          en = en_st.gets  # [#035]
          en || break
          tup = send ORDERED___.fetch( en.entry_category ), en
          tup || redo
          a.push tup
          redo
        end while above

        _a_ = a.sort_by do |(d, _)|
          d
        end

        Stream_.call _a_ do |(_, ref)|
          ref
        end
      end

      ORDERED___ = {
        association: :__on_association_when_ordering,
        operation: :__on_operation_when_ordering,
      }

      def __on_operation_when_ordering en
        op = @on_operation[ en ]
        if op
          ::Kernel._COVER_ME__no_prob__
        end
      end

      def __on_association_when_ordering en
        ref = @on_association[ en ]
        if ref
          _asc = ref.association
          [ _asc.order_ordinal_, ref ]
        end
      end

      def __execute_unordered en_st

        # hand-write a map-reduce for clarity

        Common_.stream do
          begin
            en = en_st.gets  # [#035]
            en || break
            _ivar = IVARS___.fetch en.entry_category
            x = instance_variable_get( _ivar ).call en
          end until x
          x
        end
      end

      def __do_order_fix

        cls = @_reader.ACS_.class
        if cls.const_defined? :ACS_FIX_ORDER, false
          cls::ACS_FIX_ORDER
        end
      end

      # look like a proc (sort of) for clients that assume proc-like streamer
      alias_method :call, :execute

      IVARS___ = {
        association: :@on_association,
        operation: :@on_operation,
      }

      # the below is initted lazily once per stream

      def default_on_association

        _build_thing do
          NodeReference_for_Assoc___
        end
      end

      def default_on_operation

        _build_thing do
          NodeReference_for_Operation___
        end
      end

      def _build_thing

        p = nil ; node_prototype = nil

        main = -> en do
          node_prototype.new en
        end

        p = -> first_en do  # en = entry node

          _class = yield
          node_prototype = _class.new @_reader

          ( p = main )[ first_en ]
        end

        -> en do  # first entry
          p[ en ]
        end
      end

      # <-

    class NodeReference_for_Assoc___

      def initialize rdr
        @__reader = rdr
      end

      def new_with_association__ asc
        otr = dup
        otr.instance_variable_set :@_asc_m, :__asc_via_ivar
        otr.instance_variable_set :@___asc, asc
        otr
      end

      def new en
        dup.__init en
      end

      def __init entry

        # everything is memoized; lazily. i.e: load/build/request as little
        # as necessary (and perhaps less) to satisfy what is being requested

        reader = remove_instance_variable :@__reader
        name_sym = entry.name_symbol ; entry = nil

        # --

        @_qk_m = :__qk_via_proc
        @__qk_proc = -> do
          remove_instance_variable :@__qk_proc
          _asc = send @_asc_m
          @___qk = reader.qualified_knownness_of_association _asc
          @_qk_m = :__qk_via_ivar
          send @_qk_m
        end

        # ~

        @_asc_m = :__asc_via_proc
        @__asc_proc = ->  do

          # whether or not we have produced a name by the below means,
          # overwrite it with this ("more correct") name

          remove_instance_variable :@__asc_proc
          asc = reader.read_association name_sym
          @___nf = asc.name
          @_nf_m = :__name_via_ivar
          @_asc_m = :__asc_via_ivar
          @___asc = asc
          send @_asc_m
        end

        # ~

        @_nf_m = :__name_via_proc
        @__nf_proc = -> do
          # there is a potential gotcha here - if the compasc would customize
          # the name ([sg]) it won't be represented here unless the caller has
          # requested the compasc any time before this request of the name.

          remove_instance_variable :@__nf_proc
          @_nf_m = :__name_via_ivar
          @___nf = Common_::Name.via_variegated_symbol name_sym
        end

        @name_symbol = name_sym

        self
      end

      def to_qualified_knownness
        send @_qk_m
      end
      def __qk_via_proc
        @__qk_proc[]
      end
      def __qk_via_ivar
        @___qk
      end

      def is_a_singular
        :singular_of == send( @_asc_m ).singplur_category
      end

      def association
        send @_asc_m
      end
      def __asc_via_proc
        @__asc_proc[]
      end
      def __asc_via_ivar
        @___asc
      end

      def name
        send @_nf_m
      end
      def __name_via_proc
        @__nf_proc[]
      end
      def __name_via_ivar
        @___nf
      end

      attr_reader(
        :name_symbol,
      )

      def node_reference_category
        :association
      end
    end

    class NodeReference_for_Operation___

      def initialize reader
        @_reader = reader
      end

      def new en
        dup.___init en
      end

      def ___init en
        @_entry = en
        self
      end

      def proc_to_build_formal_operation
        @_reader.read_formal_operation @_entry.name_symbol
      end

      def name
        @___nf ||= Common_::Name.via_variegated_symbol @_entry.name_symbol
      end

      def name_symbol
        @_entry.name_symbol
      end

      def node_reference_category
        :operation
      end

      def is_a_singular
        false
      end
    end
  # ->
  end
end
# #tombstone - older streamers
