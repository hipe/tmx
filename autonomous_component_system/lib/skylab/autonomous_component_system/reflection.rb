module Skylab::Autonomous_Component_System  # notes in [#002]

  module Reflection

    # -- (a simplified, hard-coded form of next major node for components only)

    to_component_association_stream = nil
    To_qualified_knownness_stream = -> acs do

      qkn_for = ACS_::Reflection_::Reader[ acs ]

      to_component_association_stream[ acs ].map_by do | asc |

        qkn_for[ asc ]
      end
    end

    to_component_association_stream = -> acs do

      asc_for = Component_Association.reader_for acs

      ACS_::Reflection_::To_entry_stream[ acs ].map_reduce_by do | entry |

        if entry.is_association

          asc_for[ entry.name_symbol ]
        end
      end
    end

    # --

    To_node_stream = -> acs do
      if acs.respond_to? :to_component_node_stream
        acs.to_component_node_stream
      else
        To_node_stream_via_inference[ acs ]
      end
    end

    class To_node_stream_via_inference  < Callback_::Actor::Monadic

      class << self
        public :new
      end  # >>

      def initialize acs
        @ACS = acs
      end

      attr_writer(
        :on_association,
        :on_operation,
      )

      def execute

        @on_association ||= method :__node_for_first_association
        @on_operation ||= method :__node_for_first_operation

        # hand-write a map-reduce for clarity

        st = Home_::Reflection_::To_entry_stream[ @ACS ]
        Callback_.stream do
          begin
            en = st.gets
            en or break
            x = instance_variable_get( IVARS___.fetch( en.category ) ).call en
            x and break
            redo
          end while nil
          x
        end
      end

      IVARS___ = {
        association: :@on_association,
        operation: :@on_operation,
      }

      def __node_for_first_association first_en

        # the below is initted lazily once per stream

        node = Node_for_Assoc___.new @ACS
        p = -> en do
          node.new en
        end
        @on_association = p
        p[ first_en ]
      end

      def __node_for_first_operation first_en

        node = Node_for_Operation___.new @ACS
        p = -> en do
          node.new en
        end
        @on_operation = p
        p[ first_en ]
      end
    end

    # "node" (in our usage here):
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
    #     based on whether the definition has been loaded yet.

    class Node_for_Assoc___

      def initialize acs

        @_asc_for = Component_Association.reader_for acs
        @_qkn_for = Home_::Reflection_::Reader[ acs ]
      end

      def new en
        dup.___init en
      end

      def ___init en
        @_entry = en
        self
      end

      def qualified_knownness
        if @_qkn_for
          _asc = association
          @__qkn = @_qkn_for[ _asc ]
          @_qkn_for = nil
        end
        @__qkn
      end

      def name
        if ! @_asc_for && @_association
          @_association.name
        else
          @___nf ||= Callback_::Name.via_variegated_symbol( @_entry.name_symbol )
        end
      end

      def association
        if @_asc_for
          @_association = @_asc_for[ @_entry.name_symbol ]
          @_asc_for = nil
        end
        @_association
      end

      def name_symbol
        @_entry.name_symbol
      end

      def category
        :association
      end
    end

    class Node_for_Operation___

      # NOTE will have short selection stack

      def initialize acs

        @_fake_selection_stack_base = [ Callback_::Known_Known[ acs ] ]
        @_init_formal = true
        @_lib = Home_::Operation::Formal_  # #violation
      end

      def new en
        dup.___init en
      end

      def ___init en
        @_entry = en
        self
      end

      def formal
        if @_init_formal
          ___init_formal
        end
        @_formal
      end

      def ___init_formal

        @_init_formal = false

        a = remove_instance_variable( :@_fake_selection_stack_base ).dup
        lib = remove_instance_variable :@_lib

        _nf = name
        a.push _nf

        _m = lib.method_name_for_symbol @_entry.name_symbol

        @_formal = lib.via_method_name_and_selection_stack _m, a

        NIL_
      end

      def name
        @___nf ||= Callback_::Name.via_variegated_symbol( @_entry.name_symbol )
      end

      def name_symbol
        @_entry.name_symbol
      end

      def category
        :operation
      end
    end

    # --

    Ivar_based_value_writer = -> acs do

      # (technically for interpretation not reflection)

      -> qkn do
        ACS_::Interpretation_::Write_via_ivar[ qkn, acs ]
      end
    end

    Ivar_based_value_reader = -> acs do

      # (similar but necessarily different from the other)

      -> asc do
        ivar = asc.name.as_ivar
        if acs.instance_variable_defined? ivar
          Callback_::Known_Known[ acs.instance_variable_get( ivar ) ]
        end
      end
    end
  end
end
