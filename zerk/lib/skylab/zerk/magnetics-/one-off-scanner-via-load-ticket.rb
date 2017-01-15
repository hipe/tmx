module Skylab::TMX

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
          OneOff___.new _slug_tail, path, @load_ticket
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

    class OneOff___

      def initialize slug_tail, path, lt
        @load_ticket = lt
        @path = path
        @slug_tail = slug_tail
        @_slug = :__slug_initially
      end

      def sub_top_level_const_guess
        @___STLCG ||= __sub_top_level_const_guess
      end

      def __sub_top_level_const_guess

        if @slug_tail
          __sub_top_level_const_guess_normally
        else
          __sub_top_level_const_guess_when_weird_name
        end
      end

      def __sub_top_level_const_guess_when_weird_name

        # for weird one-offs whose filename entry didn't match the expected
        # head (a.k.a prefix), generally we derive a name from the whole
        # filename entry inflected to look like a [#bs-029.3] "function-like
        # const" (e.g from the file entry "git-stash-untracked" we would
        # derive `Git_stash_untracked`).
        #
        # however if this name has an acronym-looking piece for the first
        # piece, we don't want to downcase the nonfirst letters (e.g !"Tmx"
        # for "tmx"). so for the first piece we always use the VERY heuristic
        # function below...

        pieces = slug.split DASH_
        _s = @load_ticket.class::Const_guess_via_piece[ pieces.first ]  # meh
        pieces[0] = _s
        pieces.join( UNDERSCORE_ ).intern
      end

      def __sub_top_level_const_guess_normally

        # for one-offs whole filename followe convention, assume:

        _ = @slug_tail.gsub DASH_, UNDERSCORE_
        "#{ @load_ticket.one_off_const_head }#{ UNDERSCORE_ }#{ _ }".intern
      end

      def program_name_tail_string_array
        [ @load_ticket.slug, slug ]
      end

      def slug
        send @_slug
      end

      def __slug_initially
        if @slug_tail
          @_slug = :__slug_using_tail
        else
          @__slug_derived = ::File.basename( @path ).freeze
          @_slug = :__slug_derived_from_path
        end
        send @_slug
      end

      def __slug_using_tail
        @slug_tail
      end

      def __slug_derived_from_path
        @__slug_derived
      end

      attr_reader(
        :load_ticket,
        :path,
      )
    end

    # ==
  end
end
# #born for one-off mounting
