module Skylab::Zerk::TestSupport

  module Fixture_Top_ACS_Classes

    class Class_36_Flag  # 3x

      class << self
        alias_method :new_cold_root_ACS_for_iCLI_test, :new
        alias_method :new_cold_root_ACS_for_niCLI_test, :new
        alias_method :new_cold_root_ACS_for_expect_root_ACS, :new
        private :new
      end  # >>

      def initialize
        @probe_lauf = false  # missing required without this
      end

      def __probe_lauf__component_association

        yield :description, -> y do
          y << "'Probelauf' is German for \"test run\"."
        end

        yield :flag
      end

      def __money__component_operation
        -> probe_lauf do
          probe_lauf
        end
      end
    end
  end
end
