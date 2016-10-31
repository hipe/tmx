module Skylab::TestSupport

  class Slowie

    class Models_::TestDirectoryCollection

      # allow multiple operations to solve for this in the same way

      def initialize operation_identifier, top_client

        @argument_scanner = top_client.argument_scanner
        @__globberer_by = top_client.method :globberer_by
        @__operation_identifier = operation_identifier
        _common_clear
      end

      def clear
        remove_instance_variable :@_test_directories
        _common_clear
      end

      def _common_clear
        @has_explicitly_named_directories = false
        @has_streamer = false
        @_receive_directory = :__receive_first_directory
        @_receive_streamer = :__receive_only_streamer
        @_to_stream = nil
      end

      # -- write

      def parse_test_directory

        # assume the head of the scanner matches whatever primary name
        # is being used to indicate test directories (probaly :test_directory)

        @argument_scanner.advance_one
        dir = @argument_scanner.parse_primary_value :must_be_trueish
        if dir
          send @_receive_directory, dir
          ACHIEVED_
        end
      end

      def __receive_first_directory dir
        @has_explicitly_named_directories = true
        @_receive_directory = :__receive_subsequent_directory
        @_test_directories = [ dir ]
        @_to_stream = :__to_stream_via_explicit_list
        NIL
      end

      def __receive_subsequent_directory dir
        @_test_directories.push dir ; nil
      end

      def test_directory_stream_once_by & p
        send @_receive_streamer, p
      end

      def __receive_only_streamer p
        @has_explicitly_named_directories && self._SANITY
        remove_instance_variable :@_receive_directory
        remove_instance_variable :@_receive_streamer
        @has_streamer = true
        @__streamer_once_p = p
        @_to_stream = :__to_stream_via_streamer_once_proc
        NIL
      end

      # -- normalize (re-entrant, so a subset of "read")

      def check_for_missing_requireds
        if @has_explicitly_named_directories
          ACHIEVED_  # hi.
        elsif @has_streamer
          ACHIEVED_  # hi.
        else
          @argument_scanner.when_missing_requireds(
            :operation_path, @__operation_identifier.path,
            :missing, [ :is_plural, "test directories", :use, :test_directory ]
          )
        end
      end

      # -- read

      def to_globber_stream

        globberer = @__globberer_by.call do |o|
          o.xx_example_globber_option_xx = :yy
        end

        to_test_directory_stream.map_by do |dir|
          globberer.globber_via_directory dir
        end
      end

      def to_test_directory_stream
        send @_to_stream
      end

      def __to_stream_via_streamer_once_proc
        _p = remove_instance_variable :@__streamer_once_p
        _st = _p.call
        _st  # #todo
      end

      def __to_stream_via_explicit_list
        Stream_[ @_test_directories ]
      end

      attr_reader(
        :has_explicitly_named_directories,
      )
    end
  end
end
