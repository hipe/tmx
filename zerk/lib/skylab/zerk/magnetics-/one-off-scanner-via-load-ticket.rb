module Skylab::Zerk

  class Magnetics_::OneOffScanner_via_LoadTicket < Actor_via_SimpleModel_  # 1x

    # how to "splay" "mountable" "one-offs"

    class << self
      def call_by & p
        define( & p ).execute
      end
      private :define  # ..
    end  # >>

    # -

      def initialize
        @stream_not_scanner = false
        yield self
      end

      attr_writer(
        :filesystem,
        :glob_entry,
        :load_ticket,
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
            st.flush_to_polymorphic_stream
          end
        elsif @stream_not_scanner
          Common_::Stream.the_empty_stream
        else
          Common_::Polymorphic_Stream.the_empty_polymorphic_stream
        end
      end

      def __resolve_nonzero_paths
        head = @load_ticket.conventional_executable_directory_
        _glob = ::File.join head, @glob_entry
        paths = @filesystem.glob _glob
        if paths.length.nonzero?
          @__head = head
          @paths = paths ; ACHIEVED_
        end
      end

      def __fluff_it_up

        rx = @load_ticket.regexp_for_path_head_of_conventional_one_off_

        Stream_.call @paths do |path|
          md = rx.match path
          if md
            _slug_tail = md.post_match
          end
          Home_::Models::OneOff.define do |o|
            o.slug_tail = _slug_tail
            o.path = path
            o.load_ticket = @load_ticket
          end
        end
      end

      def __remove_eponymous_executable
        # (do not include the eponymous executable in this listing for now..)

        d = @paths.index @load_ticket.eponymous_executable_path_guess_
        if ! d
          _thing_without_prefix = ::File.join @__head, @load_ticket.slug
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
