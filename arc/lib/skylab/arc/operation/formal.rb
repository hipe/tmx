module Skylab::Autonomous_Component_System

  module Operation

    class Formal  # 1x [mt] 1x here

      # this is a representation of whatever is expressed by the DSL in the
      # definition of an operation. this data is wrapped by this node
      # only in the interest of compartmentalization - it (as associations)
      # is [#002]:DT3 ephemeral. more in [#009].

      class << self

        def reader_of_formal_operations_by_method_in acs

          # we've decided that a "formal operation" includes the "selection
          # stack" involved in reaching it. so the reader (when successful)
          # cannot itself produce a full formal operation simply from a
          # symbolic name and an ACS. rather, the successful "read" results
          # in a proc which in turn will produce the formal operation when
          # passed a selection stack. whew!

          -> sym do

            m = :"__#{ sym }__component_operation"

            if acs.respond_to? m

              -> ss do

                ss.last || Write_name__[ ss, sym ]
                _fo = new.__init_via_method_and_selection_stack m, ss
                _fo.__evaluate_definition_via_calling_method_and_finish
              end
            end
          end
        end

        def via_by sym, ss, & p  # #experimental

          ss.last || Write_name__[ ss, sym ]
          _fo = new.__init_via_selection_stack_only ss
          _fo.__evaluate_definition_via_other_money p
        end

        private :new
      end  # >>

      Write_name__ = -> ss, sym do

        # :[#030] a sort of nasty but "good enough" solution to this design
        # problem: if for example the node was resolved fuzzily, we allow
        # that the client push false-ish on to the top of the selection stack
        # as a way of "requesting" that it be populated with an element
        # reflecting the full name.

        ss[ -1 ] = Common_::Name.via_variegated_symbol sym
        NIL_
      end

      def initialize
        @_saw_implementation = false
      end

      def __init_via_method_and_selection_stack m, ss
        @__method_name = m
        @selection_stack = ss
        self
      end

      def __init_via_selection_stack_only ss
        @selection_stack = ss ; self
      end

      def __evaluate_definition_via_calling_method_and_finish

        _m = remove_instance_variable :@__method_name

        _x = _ACS.send _m do |*x_a|
          _accept_phrase x_a
        end

        _maybe_implementation _x
        self
      end

      def __evaluate_definition_via_other_money p

        _y = ::Enumerator::Yielder.new do |*x_a|
          _accept_phrase x_a
        end

        _x = p.call _y

        _maybe_implementation _x
        self
      end

      def _accept_phrase x_a

        st = Common_::Scanner.via_array x_a
        begin
          x = send :"__accept__#{ st.gets_one }__meta_component", st
          st.no_unparsed_exists ? break : redo
        end while nil
        x
      end

      def _maybe_implementation x

        _did_see = remove_instance_variable :@_saw_implementation
        unless _did_see
          __init_normal_representation_normally x
        end
      end

      def __init_normal_representation_normally x

        if x.respond_to? :call
          nr = Here_::NormalRepresentation_for_Proc___.new x, self
        else

          _pfoz = x::PARAMETERS  # NOTE - `respond_to?` :parameters whenever
          nr = Here_::NormalRepresentation_for_NonProc___.new _pfoz, x, self
        end

        @_normal_representation = nr
        NIL_
      end

      def _ACS
        @selection_stack.fetch( -2 ).ACS
      end

      # --

      def __accept__description__meta_component st  # #during #milestone:4
        @description_proc = st.gets_one
        NIL_
      end

      attr_reader :description_proc

      # ~ availability (e.g required-ness), and parameter-level definition

      def __accept__unavailability__meta_component st
        @unavailability_proc = st.gets_one ; nil
      end

      attr_reader :unavailability_proc  # for mode-client to implement

      def __accept__parameter__meta_component st

        ACS_::Parameter.interpret_into_via_passively__ _writable_param_box, st
        NIL_
      end

      def _writable_param_box
        @parameter_box ||= Common_::Box.new
      end

      def __accept__via_ACS_by__meta_component st

        @_saw_implementation = true

        @_normal_representation =
          Here_::NormalRepresentation_for_ACS___.new st.gets_one, self

        st.assert_empty

        NIL_
      end

      def __accept__end__meta_component _
        NOTHING_  # (this keyword exists only so we can have trailing commas)
      end

      attr_reader :parameter_box

      # ~ for [ze]

      def begin_preparation & call_handler
        @_normal_representation.begin_preparation_( & call_handler )
      end

      def begin_parameter_store & call_handler
        @_normal_representation.begin_parameter_store_( & call_handler )
      end

      def formal_parameter sym  # [pe]
        @_normal_representation.__formal_parameter sym
      end

      def has_defined_formal_parameters
        @_normal_representation.__has_defined_formal_parameters
      end

      def to_defined_formal_parameter_stream
        @_normal_representation.to_defined_association_stream_memoized_
      end

      # ~

      def description_proc_thru_implementation
        @_normal_representation.desc_proc_
      end

      def name_symbol  # [ze]
        @selection_stack.fetch( -1 ).as_variegated_symbol
      end

      def name
        @selection_stack.fetch( -1 )
      end

      attr_reader :selection_stack  # [ze]

      def normal_representation_
        @_normal_representation
      end

      def formal_node_category
        :formal_operation
      end
    end

    class Normal_Representation_

      # abstract base for a #[#027] "normal representation" of a formal operation

      def deliverable_for_imperative_phrase_ ip

        ss = ip.selection_stack_ ; oes_p = ip.call_handler_

        o = self.class::Preparation.new self, ss, & oes_p

        o.PVS_parameter_stream_once = -> do
          _association_index.to_native_association_stream
        end

        o.association_index_memoized_by = -> do
          _association_index  # hi.
        end

        o.on_unavailable = NOTHING_  # raise exceptions

        o.parameter_store = begin_parameter_store_( & oes_p )

        o.parameter_value_source = ip.build_parameter_value_source_

        bc = o.to_bound_call

        bc and Here_::Delivery_::Deliverable.new( ip.modz_, ss, bc )
      end

      def begin_preparation_ & call_handler

        self.class::Preparation.new self, @formal_.selection_stack, & call_handler
      end

      def __formal_parameter sym

        _association_index.dereference_association_via_symbol__ sym
      end

      def to_defined_association_stream_memoized_

        # (case in point is [#ze-028]<->[#032] - this is requested 3 times for one invocation?)

        Stream_[ _association_index.association_array ]
      end

      def __has_defined_formal_parameters

        _association_index.association_array.length.nonzero?
      end

      def _association_index
        send( @_association_index ||= :__association_index_initially )
      end

      def __association_index_initially
        o = to_association_index_  # some memoize this remotely, but not all do
        @_association_index = :__association_index
        @__association_index = o ; o
      end

      def __association_index
        @__association_index
      end

      attr_reader(
        :formal_,
      )
    end

    class Preparation_  # #stowaway - see [#027]:"preparation"

      def initialize nr, ss, & call_handler
        @call_handler_ = call_handler  # [#ca-001] for the operation execution
        @nr_ = nr
        @_omr = nil
        @ss_ = ss
      end

      attr_writer(
        :association_index_memoized_by,
        :on_unavailable,
        :parameter_store,
        :parameter_value_source,
        :PVS_parameter_stream_once,
      )

      def check_availability_
        p = @nr_.formal_.unavailability_proc
        if p
          fo = @nr_.formal_
          unava_p = p[ fo ]
          if unava_p
            Here_::WhenNotAvailable::Act[ @on_unavailable, unava_p, fo ]
          else
            ACHIEVED_
          end
        else
          ACHIEVED_
        end
      end

      def normalize_

        # (if any of the below ivars is not set you did not set a required attribute)

        o = Home_::Parameter::Normalization.begin @ss_

        o.PVS_parameter_stream_once = @PVS_parameter_stream_once

        o.association_index_memoized_by = @association_index_memoized_by

        o.on_reasons = @on_unavailable

        o.parameter_store = @parameter_store

        o.parameter_value_source = @parameter_value_source

        o.execute
      end
    end
  end
end
