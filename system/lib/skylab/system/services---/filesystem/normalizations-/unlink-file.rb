module Skylab::System

  class Services___::Filesystem

    class Normalizations_::Unlink_File < Normalizations_::Path_Based
    private

      def initialize _fs
        @_probably_exists = false
        super
      end

      def probably_exists=

        # this flag prevents an exception from being raised when the file
        # does not exist. instead, it emits an error event in such cases.

        @_probably_exists = true
        KEEP_PARSING_
      end

      public def execute
        if @_probably_exists
          __when_probably_exists
        else
          _when_does_exist
        end
      end

      def __when_probably_exists

        begin
          _when_does_exist
        rescue ::Errno::ENOENT => e
        end

        if e
          ev = wrap_exception_ e
          @on_event_selectively.call :error, ev.terminal_channel_i do
            ev
          end
          UNABLE_
        else
          @_result
        end
      end

      def _when_does_exist

        _x = @filesystem.unlink path_
        if 1 == _x
          ACHIEVED_
        else
          self._COVER_ME
        end
      end
    end
  end
end
