module Skylab::Arc::TestSupport

  module Fixture_Top_ACS_Classes

    class Class_21_Fully_Dynamic_Nodes

      class << self
        alias_method :new_cold_root_ACS_for_want_root_ACS, :new
        private :new
      end  # >>

      def initialize
        @_injector = Injector.new
      end

      def to_component_node_reference_streamer
        @_injector.__to_comp_node_reference_streamer
      end

      class Injector

        def __to_comp_node_reference_streamer
          Home_::Magnetics::NodeReferenceStreamer_via_FeatureBranch.via_ACS self
        end

        def __assokie__component_association
          Here_::Class_91_Trueish
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
