module Skylab::TestSupport

  class Slowie

    class Models_::HashBasedSyntax

      def initialize as, h, o
        @argument_scanner = as
        @hash = h
        @operation = o
      end

      def parse_arguments
        ok = true
        until @argument_scanner.no_unparsed_exists
          ok = __parse_primary
          ok || break
        end
        ok
      end

      def __parse_primary
        m = @argument_scanner.match_head_against_primaries_hash @hash
        if m
          @operation.send m
        end
      end

      def parse_primary_at_head sym
        # NOTE - here we do NOT advance scanner head, because it is assumed
        # that it is done by the operation when the below method is called
        @operation.send @hash.fetch sym
      end

      def to_primary_normal_name_stream
        Stream_[ @hash.keys ]
      end
    end
  end
end
# #history: abstracted from two operations
