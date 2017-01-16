module Skylab::Zerk

  class Magnetics_::OneOffScanner_via_LoadTicket < SimpleModel_  # 1x

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
        :entry_glob,
        :filesystem,
        :load_ticket,
        :stream_not_scanner,  # only while [br] #[#007.G]
      )

      def execute

        @entry_glob || self._REQUIRED

        if __resolve_nonzero_paths
          __init_exponymous_entry
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
        head = ::File.join @load_ticket.gem_path, BIN___
        _glob = ::File.join head, @entry_glob
        paths = @filesystem.glob _glob
        if paths.length.nonzero?
          @_GNE = @load_ticket.gem_name_elements
          @head = head
          @paths = paths ; ACHIEVED_
        end
      end

      def __fluff_it_up
        rx = %r(\A#{ ::Regexp.escape @_eponymous_head }#{ DASH_ })
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

        d = @paths.index @_eponymous_head
        if ! d
          _thing_without_prefix = ::File.join @head, @load_ticket.slug
          # [my]
          d = @paths.index _thing_without_prefix
        end
        if d
          @paths[ d, 1 ] = EMPTY_A_
        end
        NIL
      end

      def __init_exponymous_entry

        pfx = @_GNE.exe_prefix
        slug = @load_ticket.slug

        @_eponymous_head = if pfx.include? slug and pfx[ 0 ... -1 ] == slug

          # the eponymous head for the [tmx] sidesystem is "tmx", not "tmx-tmx"

          ::File.join @head, slug
        else
          ::File.join @head, "#{ pfx }#{ slug }"
        end
        NIL
      end
    # -

    # ==

    BIN___ = 'bin'

    # ==
  end
end
# #history: moved from [tmx] to [ze]
# #born for one-off mounting
