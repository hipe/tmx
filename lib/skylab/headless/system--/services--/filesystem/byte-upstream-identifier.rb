module Skylab::Headless

  class System__::Services__::Filesystem

    class Byte_Upstream_Identifier

      # a :+[#br-019] unified interface for accessing the bytes in a file.

      def initialize path, & oes_p

        @path = path
        @on_event_selectively = oes_p

        @IO = -> do
          io = _open
          @IO = -> { io }
          io
        end
      end

      # ~ reflection

      def members
        [ :description_under,  :to_path, :to_pathname, :to_simple_line_stream ]
      end

      def description_under expr
        Headless_.lib_.basic::Pathname.description_under_of_path expr, @path
      end

      def to_pathname
        @path and ::Pathname.new @path_s
      end

      def to_path
        @path
      end

      # ~ data delivery

      def whole_string
        ::File.read @path
      end

      def to_simple_line_stream
        ::File.open @path, READ_MODE_
      end
    end
  end
end
