module Skylab::Zerk

  class Magnetics_::OneOffScanner_via_LoadTicket

    # experiment with giving "one-offs" a more formal treatment

    class << self
      def call lt, fs
        head = ::File.join lt.gem_path, BIN___
        _glob = ::File.join head, GLOB___
        these = fs.glob _glob
        if these.length.zero?
          Common_::Polymorphic_Stream.the_empty_polymorphic_stream
        else
          new( these, head, lt, fs ).execute
        end
      end
      alias_method :[], :call
      private :new
    end  # >>

    # -
      def initialize * four
        @paths, @head, @load_ticket, @filesystem = four

        @_GNE = @load_ticket.gem_name_elements
      end

      def execute

        __init_exponymous_entry

        __remove_eponymous_executable

        if @paths.length.zero?
          Common_::Polymorphic_Stream.the_empty_polymorphic_stream
        else
          __fluff_it_up
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
        end.flush_to_polymorphic_stream
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

    BIN___ = 'bin' ; GLOB___ = '*'

    # ==
  end
end
# #history: moved from [tmx] to [ze]
# #born for one-off mounting
