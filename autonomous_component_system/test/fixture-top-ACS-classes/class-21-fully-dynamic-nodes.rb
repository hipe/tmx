module Skylab::Autonomous_Component_System::TestSupport

  module Fixture_Top_ACS_Classes

    class Class_21_Fully_Dynamic_Nodes

      def initialize
        @_injector = Injector.new
      end

      def to_component_node_stream
        @_injector.__to_comp_ns
      end

      class Injector

        def __to_comp_ns
          Home_::Reflection::To_node_stream_via_inference[ self ]
        end

        def __assokie__component_association
          Here_::Class_72_Trueish
        end

        def __opie__component_operation
          -> do
            self.hello
          end
        end

        def hello
          :_i_am_from_injector_
        end
      end
    end
  end
end
