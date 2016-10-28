module Skylab::TestSupport

  class Slowie

    class Operations::ListFiles

      if false
        y << "a stream of each test file path"
      end

      # (if you don't know what a "globber" is, see #slowie-spot-1)

      def initialize
        o = yield
        @argument_scanner = o.argument_scanner
        @globberer_by = o.method :globberer_by
        @_emit = o.listener

        @_test_directory_collection = Here_::Models_::TestDirectoryCollection.
          new :list_files, o
      end

      def execute
        if __normal
          __flush_path_stream_normally
        else
          UNABLE_
        end
      end

      def __flush_path_stream_normally

        globber_st = __globber_stream
        if globber_st
          globber_st.expand_by do |globber|
            globber.to_path_stream
          end
        end
      end

      def __globber_stream

        globberer = @globberer_by.call do |o|
          o.xx_example_globber_option_xx = :yy
        end

        @_test_directory_collection.to_nonempty_test_directory_stream.map_by do |dir|
          globberer.globber_via_directory dir
        end
      end

      # -- parsing arguments (do it yourself for clarity & flexibility)

      def __normal
        if __parse_args
          @_test_directory_collection.check_for_missing_requireds
        end
      end

      def __parse_args
        ok = true
        until @argument_scanner.no_unparsed_exists
          ok = __parse_primary
          ok || break
        end
        ok
      end

      def __parse_primary
        m = @argument_scanner.match_head_against_primaries_hash PRIMARIES___
        if m
          send m
        end
      end

      PRIMARIES___ = {
        test_directory: :__parse_test_directory,
      }

      def __parse_test_directory
        @_test_directory_collection.parse_test_directory
      end
    end
  end
end
# #tombstone: verbose behavior should probably not be implemented in the backend..
