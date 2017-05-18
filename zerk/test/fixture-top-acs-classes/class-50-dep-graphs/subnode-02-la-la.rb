module Skylab::Zerk::TestSupport

  module Fixture_Top_ACS_Classes

    class Class_50_Dep_Graphs::Subnode_02_LA_LA

      class << self
        alias_method :new_cold_root_ACS_for_expect_root_ACS, :new
        undef_method :new
      end  # >>

      def __ounces_of_water__component_association
        -> st do
          Common_::KnownKnown[ st.gets_one ]
        end
      end

      def __instant_coffee__component_operation
        Inst_Coff
      end

      def __boil_water__component_operation
        Boil_H20
      end

      Field__ = Field_lib_for_testing_[]

      class Inst_Coff

        PARAMETERS = Field__::Attributes[
          boil_water: nil,
        ]

        attr_writer(
          :boil_water,
        )

        def finish__boil_water__by o
          o.tempurature = 100
          o.execute
        end

        def execute
          "(coffee via #{ @boil_water })"
        end
      end

      class Boil_H20

        PARAMETERS = Field__::Attributes[
          ounces_of_water: nil,
        ]

        attr_writer(
          :tempurature,
          :ounces_of_water,
        )

        def initialize
          @tempurature = nil
        end

        def execute
          if @tempurature
            _plus = " at #{ @tempurature }˚"
          end
          "(boiling #{ @ounces_of_water } oz of H20#{ _plus })"
        end
      end
    end
  end
end
