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

                if ! ss.last  # kind of nasty [#030]: it is convenient for
                  # fuzzy lookup to be told what the actual name (symbol)
                  # is that was resolved, otherwise `sym` is inaccessible.
                  ss[ -1 ] = Callback_::Name.via_variegated_symbol sym
                end

                _fo = new.___init_via m, ss
                _fo.__evaluate_definition_and_finish
              end
            end
          end
        end

        private :new
      end  # >>

      def ___init_via m, ss
        @_method_name = m
        @selection_stack = ss
        self
      end

      def __evaluate_definition_and_finish

        x = _ACS.send @_method_name do | * x_a |

          st = Callback_::Polymorphic_Stream.via_array x_a
          begin
            send :"__accept__#{ st.gets_one }__meta_component", st
            st.no_unparsed_exists and break
            redo
          end while nil
          NIL_
        end

        if x.respond_to? :call
          nr = Here_::NormalRepresentation_for_Proc___.new x, self
        else

          _pfoz = x::PARAMETERS  # NOTE - `respond_to?` :parameters whenever
          nr = Here_::NormalRepresentation_for_NonProc___.new _pfoz, x, self
        end

        @_normal_representation = nr
        self
      end

      def _ACS
        @selection_stack.fetch( -2 ).ACS
      end

      def ___accept_proc_as_implementation x
        NIL_
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
        @box ||= Callback_::Box.new
      end

      attr_reader :box

      # ~ for [ze]

      def begin_preparation & call_handler
        @_normal_representation.begin_preparation_( & call_handler )
      end

      def begin_parameter_store & call_handler
        @_normal_representation.begin_parameter_store_( & call_handler )
      end

      def to_defined_formal_parameter_stream
        @_normal_representation.to_defined_formal_parameter_stream_cached_
      end

      # ~

      def normal_representation_
        @_normal_representation
      end

      def name_symbol  # [ze]
        @selection_stack.fetch( -1 ).as_variegated_symbol
      end

      def name
        @selection_stack.fetch( -1 )
      end

      attr_reader :selection_stack  # [ze]

      def formal_node_category
        :formal_operation
      end
    end

    class Normal_Representation_

      # abstract base for a #[#027] "normal representation" of a formal operation

      def deliverable_for_imperative_phrase_ ip

        ss = ip.selection_stack_ ; oes_p = ip.call_handler_

        o = self.class::Preparation.new self, ss, & oes_p

        o.bespoke_stream_once = -> do
          to_defined_formal_parameter_stream_cached_
        end

        o.expanse_stream_once = -> do
          to_defined_formal_parameter_stream_cached_
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

      def to_defined_formal_parameter_stream_cached_

        # (case in point is [#ze-028]<->[#032] - this is requested 3 times for one invocation?)

        @__etc_ ||= to_defined_formal_parameter_stream_to_be_cached_.to_a
        Callback_::Stream.via_nonsparse_array @__etc_
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
        :bespoke_stream_once,
        :expanse_stream_once,
        :on_unavailable,
        :parameter_store,
        :parameter_value_source,
      )

      def check_availability_
        p = @nr_.formal_.unavailability_proc
        if p
          fo = @nr_.formal_
          unava_p = p[ fo ]
          if unava_p
            Here_::When_Not_Available::Act[ @on_unavailable, unava_p, fo ]
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

        o.bespoke_stream_once = @bespoke_stream_once

        o.expanse_stream_once = @expanse_stream_once

        o.on_reasons = @on_unavailable

        o.parameter_store = @parameter_store

        o.parameter_value_source = @parameter_value_source

        o.execute
      end
    end
  end
end
