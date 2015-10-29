module Skylab::Brazen

  module Autonomous_Component_System

    class Operation  # experimental dsl for "rich" operations

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
      end

      def _init_for_sym sym

        @name_symbol = sym

        _p = @_acs.send :"__#{ sym }__component_operation" do | * x_a |

          st = Callback_::Polymorphic_Stream.via_array x_a
          send :"__accept__#{ st.gets_one }__meta_component", st
          NIL_
        end

        @callable = _p

        self
      end

      def __say x
        "results from component operation definitions must be nil (had #{ x.class })"
      end

      def name
        @___nf ||= Callback_::Name.via_variegated_symbol @name_symbol
      end

      def __accept__parameter__meta_component st

        @_mutable_parameter_box ||= Callback_::Box.new

        ACS_::Parameter.interpret_into_via @_mutable_parameter_box, st

        NIL_
      end

      def callable
        @_done || _finish
        @callable
      end

      def formal_properties

        @_done || _finish
        @_mutable_parameter_box
      end

      def _finish

        @_done = true

        @_mutable_parameter_box ||= Callback_::Box.new

        ACS_::Parameter.collection_into_via_mutable_platform_parameters(
          @_mutable_parameter_box,
          @callable.parameters,
        )
        NIL_
      end

      def association  # (look like qkn for now)
        self
      end

      def category
        :operation
      end
    end
  end
end
