module Skylab::TestSupport

  class Slowie

    class Models_::TestDirectoryCollection

      # allow multiple operations to solve for this in the same way

      def initialize operation_path, client

        @argument_scanner = client.argument_scanner
        @_has_some = false
        @operation_path = operation_path
        @_receive = :__receive_first_directory
      end

      # -- write

      def parse_test_directory

        # assume the head of the scanner matches whatever primary name
        # is being used to indicate test dirctories (probaly :test_directory)

        @argument_scanner.advance_one
        dir = @argument_scanner.parse_primary_value :must_be_trueish
        if dir
          send @_receive, dir
          ACHIEVED_
        end
      end

      def __receive_first_directory dir
        @_has_some = true
        @_test_directories = [ dir ]
        @_receive = :__receive_subsequent_directory ; nil
      end

      def __receive_subsequent_directory dir
        @_test_directories.push dir ; nil
      end

      # -- normalize (re-entrant, so a subset of "read")

      def check_for_missing_requireds
        if @_has_some
          ACHIEVED_
        else
          @argument_scanner.when_missing_requireds(
            :operation_path, @operation_path,
            :missing, [ :is_plural, "test directories", :use, :test_directory ]
          )
        end
      end

      # -- read

      def to_nonempty_test_directory_stream  # assume.
        Stream_[ @_test_directories ]
      end
    end
  end
end
