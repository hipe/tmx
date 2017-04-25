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

      def modality_const
        :ByteStream
      end

      # ..

      def is_same_waypoint_as otr

        # ultimately it's the filesystem's responsibility (not ours) to
        # decide how an inode (file) is resolved from a string, and most (if
        # not all) filesystems allow for more than just one string to resolve
        # to the same inode:
        #
        #     "/some/FILE", "some/file"  # same file on HFS (iOS)
        #
        #     "/some/./file", "/some/file"  # same file (probaly most FS's)
        #
        #     "file", "/some/file"  # same file if you are "in" the "/some" directory
        #
        # to implement the subject method "robustly" would then probably
        # involve .. we're not even sure how we'd do it.
        #
        # while we don't want to go crazy implementing this to a degree of
        # robustness that would involve coupling too tightly to the system,
        # we would hate to get bit by cases like the second example above,
        # that are easy enough to detect without going into the system.
        # so here is our middle-ground compromise for good-enough robustity:

        if :path == otr.shape_symbol

          otr_path = otr.path

          # (for many cases we would save work by just short-circuiting on
          # string equality here, but we want to exercise the machinery)

          if Path_looks_absolute_[ @path ]
            if Path_looks_absolute_[ otr_path ]

              _use_path = ::File.expand_path @path
              _use_path_ = ::File.expand_path otr_path
              _use_path == _use_path_

            else
              self._COVER_ME__not_recommended_to_use_this_with_any_relative_paths
            end
          else
            self._COVER_ME__not_recommended_to_use_this_with_any_relative_paths
          end
        end
      end

      attr_reader(
        :path,
      )

      def shape_symbol
        :path
      end

    end
  end
end
