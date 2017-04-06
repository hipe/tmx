module Skylab::System

  module Filesystem

    class ByteUpstreamReference  # [#003].

      # a #[#ba-062] unified interface for accessing the bytes in a file.

      def initialize path, & oes_p

        @_to_rewound_shareable = :__to_rewound_shareable_intially

        @path = path
        @on_event_selectively = oes_p
      end

      # -- data delivery

      def whole_string
        ::File.read @path
      end

      # ~

      def TO_REWOUND_SHAREABLE_LINE_UPSTREAM_EXPERIMENT & p
        send @_to_rewound_shareable, & p
      end

      def __to_rewound_shareable_intially & p

        @_IO_ = _to_rewindable_line_stream p
        send( @_to_rewound = :__to_rewound_shareable_subsequently )
      end

      def __to_rewound_shareable_subsequently
        @_IO_.rewind
        @_IO_
      end

      attr_reader :_IO_  # during dev

      # ~

      def to_simple_line_stream & p
        _to_rewindable_line_stream p
      end

      def _to_rewindable_line_stream p

        if p  # experimental convenience exposure, covered by [sn]

          kn = Home_::Filesystem::Normalizations::Upstream_IO.via(
            :path, @path,
            :filesystem, Home_.services.filesystem,
            & p
          )
          kn && kn.value_x

        else
          ::File.open @path, ::File::RDONLY
        end
      end

      # -- conversion, standard readers, reflection, etc

      def to_byte_downstream_reference
        Home_::Filesystem::ByteDownstreamReference.new @path, & @on_event_selectively
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
