module Skylab::TMX

  class Models_::LoadTicket  # #testpoint

    # -
      def initialize gne  # GemNameElements_

        @require_path = gne.gem_name.gsub DASH_, ::File::SEPARATOR
        @gem_name_elements = gne
        __init_const_path_array_guess
      end

      def __init_const_path_array_guess

        # (see [#002.A] re: a gem name many segments, segment is many pieces)

        const_path_guess = []
        gne = @gem_name_elements

        # guess each const

        gne.gem_name.split( DASH_ ).each do |segment|
          const_path_guess.push Const_guess_via_segment___[ segment ]
        end

        # confirm that the head segments line up

        gne.const_head_path.each_with_index do |sym, d|
          const_path_guess.fetch( d ) == sym && next
          self._NAME_SANITY
        end

        @const_path_array_guess = const_path_guess.freeze ; nil
      end

      def require_sidesystem_module
        @____sidesys_mod ||= __induce_sidesystem_module
      end

      def __induce_sidesystem_module  # #testpoint

        require @require_path

        # we avoid using `const_reduce` (for name correction) unless we
        # need to (for no good reason).
        # this is near but not the same as a [#tmx-018.1] mountable one-off

        mod = ::Object
        sym_a = const_path_array_guess
        ( sym_a.length - 1 ).times do |d|
          mod = mod.const_get sym_a.fetch d  # until it fails
        end

        const = sym_a.fetch( -1 )

        if mod.const_defined? const, false
          mod.const_get const, false
        else
          # (strange - probably a holdover from when we had old toplevel names)
          _ = Autoloader_.const_reduce [ const ], mod
          _
        end
      end

      def to_one_off_scanner_via_filesystem fs
         Home_::Magnetics_::OneOffScanner_via_LoadTicket[ self, fs ]
      end

      def one_off_const_head
        @___one_off_const_head ||= __one_off_const_head
      end

      def __one_off_const_head

        if ALL_CAPS___ =~ @const_path_array_guess.last  # see #here-1
          @const_path_array_guess.last.id2name.freeze
        else
          s = entry_string
          "#{ s[0].upcase }#{ s[1..-1] }".freeze
        end
      end

      ALL_CAPS___ = /\A[A-Z0-9_]+\z/

      def gem_path
        @gem_name_elements.gem_path
      end

      def slug
        @___slug ||= entry_string.gsub( UNDERSCORE_, DASH_ ).freeze
      end

      def intern
        @___as_intern ||= @gem_name_elements.entry_string.intern
      end

      def entry_string
        @gem_name_elements.entry_string
      end

      attr_reader(
        :const_path_array_guess,
        :gem_name_elements,
        :require_path,
      )

      def IS_LOAD_TICKET_tmx_  # temporary
        true
      end
    # -

    # ==

    # see #tombstone-C in other file, was #wish [#co-067]

    Const_guess_via_segment___ = -> do
      work = -> segment do
        segment.split( UNDERSCORE_ ).map do |piece|
          Const_guess_via_piece[ piece ]
        end.join( EMPTY_S_ ).intern
      end
      cache = {}
      -> segment do
        cache.fetch segment do
          x = work[ segment ]
          cache[ segment ] = x
          x
        end
      end
    end.call

    Const_guess_via_piece = -> do

      # our weak, rough heuristic for guessing if a string is "probably an
      # acronym" is that it must match all of the following criteria:
      #
      #   1) it must be 4 characters long or fewer.
      #      (allow "HTTP" as a long acronym. more that four letters long
      #      and it has no business being an acronym around here.)
      #
      #   2) all the nonfirst characters must be consonants or digits
      #
      # cases we are trying to match: CSS, TMX
      #
      # cases that would certainly fail: EPA

      ucfirst = -> s do
        "#{ s[0].upcase }#{ s[1..-1] }"
      end

      is_probably_acronym_rx = /\A[a-z][bcdfghjklmnpqrstvwxz0-9]+\z/

      work = -> piece do
        if 4 < piece.length
          # save the trouble - if it's not a TLA or a FLA, it should not be an acrony
          ucfirst[ piece ]
        else
          # hi. (code, CSS, cull, doc, test, git, TMX)
          if is_probably_acronym_rx =~ piece
            piece.upcase
          else
            ucfirst[ piece ]
          end
        end
      end

      cache = {}

      -> piece do
        cache.fetch piece do
          x = work[ piece ]
          cache[ piece ] = x.freeze
          x
        end
      end
    end.call

    # ==
  end
end
# #history: broke out from "installation" model
