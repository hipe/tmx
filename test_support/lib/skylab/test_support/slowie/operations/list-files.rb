module Skylab::TestSupport

  class Slowie

    class Operations::ListFiles

      if false
        y << "a stream of each test file path"
      end

      # (if you don't know what a "globber" is, see #slowie-spot-1)

      def initialize

        o = yield
        _op_id = OperationIdentifier_.new :list_files

        @_syntax = Here_::Models_::HashBasedSyntax.new(
          o.argument_scanner, PRIMARIES___, self )

        @test_directory_collection = Here_::Models_::TestDirectoryCollection.new(
          _op_id, o )
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

      # == mostly boilerplate below (here for clarity)

      def __normal
        _yes = @_syntax.parse_arguments
        _yes &&= @test_directory_collection.check_for_missing_requireds
        _yes  # #todo
      end

      # -- for [#006]

      def parse_primary_at_head sym
        @_syntax.parse_primary_at_head sym
      end

      def to_primary_normal_name_stream
        @_syntax.to_primary_normal_name_stream
      end

      # --

      PRIMARIES___ = {
        test_directory: :__parse_test_directory,
      }

      def __parse_test_directory
        @test_directory_collection.parse_test_directory
      end
    end
  end
end
# #tombstone: verbose behavior should probably not be implemented in the backend..
