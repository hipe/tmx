module Skylab::System

  module Filesystem

    class Byte_Upstream_Identifier  # [#003].

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

      # ~ data delivery

      def whole_string
        ::File.read @path
      end

      def to_simple_line_stream & x_p
        to_rewindable_line_stream( & x_p )
      end

      def to_rewindable_line_stream & x_p

        if block_given?  # experimental convenience exposure

          Home_.services.filesystem( :Upstream_IO ).against_path @path, & x_p
        else
          ::File.open @path, ::File::RDONLY
        end
      end

      # ~ conversion, standard readers, reflection, etc

      def to_byte_downstream_identifier
        Home_::Filesystem::Byte_Downstream_Identifier.new @path, & @on_event_selectively
      end

      def is_same_waypoint_as x
        :path == x.shape_symbol && @path == x.path  # can fail because etc.
      end

      def description_under expr
        Basic_[]::Pathname.description_under_of_path expr, @path
      end

      def name
        NIL_  # for [#ac-007] expressive events, this class name is not pretty
      end

      def to_pathname
        @path and ::Pathname.new @path_s
      end

      def to_path
        @path
      end

      attr_reader(
        :path,
      )

      def shape_symbol
        :path
      end

      def modality_const
        :ByteStream
      end
    end
  end
end
