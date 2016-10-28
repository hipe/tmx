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
        @_test_directories = nil
      end

      def execute
        if __normal
          _flush_path_stream_normally
        else
          UNABLE_  # (anything other than a stream is failure)
        end
      end

      def _flush_path_stream_normally

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

        Stream_.call @_test_directories do |dir|
          globberer.globber_via_directory dir
        end
      end

      # -- parsing arguments

      def __normal
        if __parse_args
          __check_for_missing_required
        end
      end

      def __check_for_missing_required
        if @_test_directories
          ACHIEVED_
        else
          @argument_scanner.when_missing_requireds(
            :operation_path, :list_files,
            :missing, [ :is_plural, "test directories", :use, :test_directory ]
          )
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
        @argument_scanner.advance_one
        dir = @argument_scanner.parse_primary_value :must_be_trueish
        if dir
          ( @_test_directories ||=[] ).push dir
          ACHIEVED_
        end
      end
    end
  end
end
# #tombstone: verbose behavior should probably not be implemented in the backend..
