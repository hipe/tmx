module Skylab::Brazen

  module Autonomous_Component_System

    class Operation  # experimental dsl for "rich" operations. notes in [#083]

      class << self

        def via_symbol_and_component sym, acs

          new( acs )._init_for_sym sym
        end

        def builder_for acs

          proto = new acs
          -> sym do
            proto.dup._init_for_sym sym
          end
        end

        private :new
      end  # >>

      def initialize acs

        @_acs = acs
        @_done = false
        @prototype_parameter = nil
      end

      def _init_for_sym sym

        @name_symbol = sym

        _p = @_acs.send :"__#{ sym }__component_operation" do | * x_a |

          st = Callback_::Polymorphic_Stream.via_array x_a
          begin
            send :"__accept__#{ st.gets_one }__meta_component", st
            st.no_unparsed_exists and break
            redo
          end while nil
          NIL_
        end

        @callable = _p

        self
      end

      def __accept__end__meta_component _

        # this no-op is only so that we can have lines with trailing commas
        # in yield which has syntactically different rules than a method call

        NIL_
      end

      # ~ description & name

      def __accept__description__meta_component st

        @description_block = st.gets_last_one
        NIL_
      end

      def name
        @___nf ||= Callback_::Name.via_variegated_symbol @name_symbol
      end

      attr_reader(
        :description_block,
        :name_symbol,
      )

      # ~ parameters

      def __accept__parameters__meta_component st

        @prototype_parameter ||= ACS_::Parameter.new_prototype
        @prototype_parameter.mutate_against_polymorphic_stream_passively st

        NIL_
      end

      def __accept__parameter__meta_component st

        @_mutable_parameter_box ||= Callback_::Box.new

        ACS_::Parameter.interpret_into_via_passively_ @_mutable_parameter_box, st

        NIL_
      end

      def formal_properties_in_callable_signature_order
        @___ordered ||= __order
        @__ordered_mutable_parameter_box
      end

      def __order

        bx = formal_properties
        bx_ = Callback_::Box.allocate.init bx.a_.dup, bx.h_  # careful!

        _h = ::Hash[ @callable.parameters.each_with_index.map do | (_, k), d |
          [ k,d ]
        end ]

        bx_.a_.sort_by!( & _h.method( :fetch ) )

        @__ordered_mutable_parameter_box = bx_
        ACHIEVED_
      end

      def formal_properties

        @_done || _finish
        @_mutable_parameter_box
      end

      attr_reader(
        :prototype_parameter,
      )

      # ~

      def callable
        @_done || _finish
        @callable
      end

      # ~ support

      def _finish

        @_done = true

        @_mutable_parameter_box ||= Callback_::Box.new

        ACS_::Parameter.collection_into_via_mutable_platform_parameters(
          @_mutable_parameter_box,
          @callable.parameters,
        )
        NIL_
      end

      # ~ intrinsic reflection

      def association  # (look like qkn for now)
        self
      end

      def category
        :operation
      end
    end
  end
end
