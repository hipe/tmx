module Skylab::System

  class Services___::Filesystem

    class Byte_Upstream_Identifier  # [#011].

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

      def is_same_waypoint_as x
        :path == x.shape_symbol && @path == x.path  # can fail because etc.
      end

      def description_under expr
        System_.lib_.basic::Pathname.description_under_of_path expr, @path
      end

      def shape_symbol
        :path
      end

      def modality_const
        :Byte_Stream
      end

      attr_reader :path

      # ~~ off-grid reflection

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

      def to_simple_line_stream & x_p
        to_rewindable_line_stream( & x_p )
      end

      def to_rewindable_line_stream & oes_p

        if block_given?  # experimental convenience exposure

          System_.services.filesystem.normalization.upstream_IO @path, & oes_p
        else
          ::File.open @path, ::File::RDONLY
        end
      end

      # ~ fun etc.

      def to_byte_downstream_identifier
        Filesystem_::Byte_Downstream_Identifier.new @path, & @on_event_selectively
      end
    end
  end
end
