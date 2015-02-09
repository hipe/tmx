module Skylab::Headless

  class System__::Services__::Filesystem

    class Byte_Upstream_Identifier

      def initialize path, & oes_p
        @path = path
        @on_event_selectively = oes_p
      end

      def whole_string
        ::File.read @path
      end
    end
  end
end
