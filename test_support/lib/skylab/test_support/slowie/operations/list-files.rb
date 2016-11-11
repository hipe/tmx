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

      # (if you don't know what a "globber" is, see #slowie-spot-1)

      def initialize

        o = yield

        @syntax_front = Here_::Models_::HashBasedSyntax.new(
          o.argument_scanner, PRIMARIES, self )

        @test_directory_collection = o.build_test_directory_collection
      end

      attr_reader(  # for pre-execution syntax hacks
        :test_directory_collection,
      )

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

      def __normal
        _yes = @syntax_front.parse_arguments
        _yes &&= @test_directory_collection.check_for_missing_requireds
        _yes  # #todo
      end

      # [#tmx-006] and friends

      attr_reader(
        :syntax_front,
      )

      def parse_present_primary_for_syntax_front_via_branch_hash_value m
        send m
      end

      def __parse_test_directory
        @test_directory_collection.parse_test_directory
      end
    end
  end
end
# #tombstone: verbose behavior should probably not be implemented in the backend..
