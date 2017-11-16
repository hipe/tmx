module Skylab::TestSupport

  class Slowie

    class Operations::ListFiles

      DESCRIPTION = -> y do
        y << "a stream of each test file path"
      end

      DESCRIPTIONS = {
        test_directory: DESCRIPTION_FOR_TEST_DIRECTORY_,
      }

      PRIMARIES = {
        test_directory: :__parse_test_directory,
      }

      # (a "globber" is .. #slowie-spot-1)

      def initialize

        @feature_branch = Zerk_::ArgumentScanner::FeatureBranch_via_Hash[ PRIMARIES ]

        o = yield

        @__argscn = o.argument_scanner
        @test_directory_collection = o.build_test_directory_collection
      end

      def execute
        if __normal
          globber_st = @test_directory_collection.to_globber_stream
          if globber_st
            globber_st.expand_by do |globber|
              globber.to_path_stream
            end
          end
        else
          UNABLE_
        end
      end

      # == boilerplate

      def at_from_syntaxish bi
        send bi.branch_item_value
      end

      def __normal
        _ok = Parse_any_remaining_[ self, remove_instance_variable( :@__argscn ) ]
        _ok && @test_directory_collection.check_for_missing_requireds
      end

      def __parse_test_directory
        @test_directory_collection.parse_test_directory
      end

      attr_reader(  # for pre-execution syntax hacks
        :feature_branch,
        :test_directory_collection,
      )
    end
  end
end
# #tombstone: verbose behavior should probably not be implemented in the backend..
