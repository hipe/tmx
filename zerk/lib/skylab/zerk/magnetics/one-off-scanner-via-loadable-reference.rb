module Skylab::Zerk

  class Magnetics::OneOffScanner_via_LoadableReference < Home_::MagneticBySimpleModel  # 1x

    # how to "splay" "mountable" "one-offs"

    # -

      def initialize
        @stream_not_scanner = false
        yield self
      end

      attr_writer(
        :filesystem,
        :glob_entry,
        :loadable_reference,
        :stream_not_scanner,  # only while [br] #[#007.G]
      )

      def execute

        @glob_entry || self._REQUIRED

        if __resolve_nonzero_paths
          __remove_eponymous_executable
          if @paths.length.nonzero?
            st = __fluff_it_up
          end
        end

        if st
          if @stream_not_scanner
            st
          else
            st.flush_to_scanner
          end
        elsif @stream_not_scanner
          Common_::THE_EMPTY_STREAM
        else
          Common_::THE_EMPTY_SCANNER
        end
      end

      def __resolve_nonzero_paths
        head = @loadable_reference.conventional_executable_directory_
        _glob = ::File.join head, @glob_entry
        paths = @filesystem.glob _glob
        if paths.length.nonzero?
          @__head = head
          @paths = paths ; ACHIEVED_
        end
      end

      def __fluff_it_up

        rx = @loadable_reference.regexp_for_path_head_of_conventional_one_off_

        Stream_.call @paths do |path|
          md = rx.match path
          if md
            _slug_tail = md.post_match
          end
          Home_::Models::OneOff.define do |o|
            o.slug_tail = _slug_tail
            o.path = path
            o.loadable_reference = @loadable_reference
          end
        end
      end

      def __remove_eponymous_executable
        # (do not include the eponymous executable in this listing for now..)

        d = @paths.index @loadable_reference.eponymous_executable_path_guess_
        if ! d
          _thing_without_prefix = ::File.join @__head, @loadable_reference.slug
          # [my]
          d = @paths.index _thing_without_prefix
        end
        if d
          @paths[ d, 1 ] = EMPTY_A_
        end
        NIL
      end
    # -

    # ==

    # ==
  end
end
# #history: moved from [tmx] to [ze]
# #born for one-off mounting
