module Skylab::GitViz::TestSupport

  module Mock_1  # a "business" "test bundle" (employed via 'use :mock_1')
    # that is used in junction with using the mock repository of the same name.

    def self.[] test_node
      test_node.include Instance_Methods__
    end

    module Instance_Methods__

      def expect_informational_emissions_for_mock_1
        expect_this_many_system_commands 8
        expect_this_many_statements_about_omissions 2
        expect_no_more_emissions
      end

      def expect_this_many_system_commands d
        expect_this_many_of_this d, NEXT_SYSTEM_COMMAND__
      end

      NEXT_SYSTEM_COMMAND__ = %i( next_system command ).freeze

      def expect_this_many_statements_about_omissions d
        expect_this_many_of_this d, STATEMENTS_OF_OMISSION__
      end

      STATEMENTS_OF_OMISSION__ =
        %i( info string omitting_informational_commitpoint ).freeze

      def expect_this_many_of_this d, a
        d.times do
          expect a
        end
      end
    end
  end
end
