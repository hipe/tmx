module Skylab::Autonomous_Component_System

  module Reflection

    class Node_Ticket_Streamer  # :[#036]

      # a "streamer" generally is a performer that produces a stream
      # (re-entrantly): it's like a proc that you can call multiple times,
      # each time producing a new same-ish stream.
      #
      # the subject streamer produces streams of what we now call
      # "node tickets". the "node ticket":
      #
      #   • munges generally operations and components (and whatever else
      #     similar we might come up with).
      #
      #   • facilitates the delivery of both operation- and component- related
      #     values in a semi-uniform way.
      #
      #   • is an implementation of a #[#018] "load ticket" - resolves the
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

          _rw = Home_::ReaderWriter.for_componentesque acs
          ___via_reader _rw
        end

        def ___via_reader rdr
          rdr.to_node_ticket_streamer
        end

        def via_reader__ x
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

      def execute

        @on_association ||= method :__node_for_first_association
        @on_operation ||= method :__node_for_first_operation

        # hand-write a map-reduce for clarity

        st = @_reader.to_entry_stream__
        Callback_.stream do
          begin
            en = st.gets  # [#035]
            en or break
            _ivar = IVARS___.fetch en.entry_category
            x = instance_variable_get( _ivar ).call en
            x and break
            redo
          end while nil
          x
        end
      end

      # look like a proc (sort of) for clients that assume proc-like streamer
      alias_method :call, :execute

      IVARS___ = {
        association: :@on_association,
        operation: :@on_operation,
      }

      def __node_for_first_association first_en

        # the below is initted lazily once per stream

        node = NodeTicket_for_Assoc___.new @_reader
        p = -> en do
          node.new en
        end
        @on_association = p
        p[ first_en ]
      end

      def __node_for_first_operation first_en

        node = NodeTicket_for_Operation___.new @_reader
        p = -> en do
          node.new en
        end
        @on_operation = p
        p[ first_en ]
      end

      # <-

    class NodeTicket_for_Assoc___

      def initialize rdr
        @__reader = rdr
      end

      def new en
        dup.__init en
      end

      def __init en

        # everything is memoized; lazily. i.e: load/build/request as little
        # as necessary (and perhaps less) to satisfy what is being requested

        reader = remove_instance_variable :@__reader
        name_sym = en.name_symbol ; en = nil

        @_qk = -> do
          _asc = @_asc[]
          qk = reader.qualified_knownness_of_association _asc
          @_qk = -> { qk }
          qk
        end

        @_asc = -> do
          asc = reader.read_association name_sym
          # (whether or not we have produced a name by the below means,
          # overwrite it with this ("more correct") name)
          nf = asc.name
          @_name = -> { nf }
          @_asc = -> { asc }
          asc
        end

        @_name = -> do
          # there is a potential gotcha here - if the compasc would customize
          # the name ([sg]) it won't be represented here unless the caller has
          # requested the compasc any time before this request of the name.
          nf = Callback_::Name.via_variegated_symbol name_sym
          @_name = -> { nf }
          nf
        end

        @name_symbol = name_sym

        self
      end

      def to_qualified_knownness
        @_qk[]
      end

      def association
        @_asc[]
      end

      def name
        @_name[]
      end

      attr_reader(
        :name_symbol,
      )

      def node_ticket_category
        :association
      end
    end

    class NodeTicket_for_Operation___

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
        @___nf ||= Callback_::Name.via_variegated_symbol( @_entry.name_symbol )
      end

      def name_symbol
        @_entry.name_symbol
      end

      def node_ticket_category
        :operation
      end
    end
  # ->
    end
  end
end
# #tombstone - older streamers
