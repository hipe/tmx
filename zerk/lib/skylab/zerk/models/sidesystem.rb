module Skylab::Zerk

  module Models::Sidesystem

    # an important note about the nodes defined here:
    # as the const names imply ([#bs-029.0]), these are (very much) a part of
    # our #public-API. these nodes are used heavily by [tmx] (#testpoint too)

    # ==

    LoadTicketMethods__ = ::Module.new

    # `_const_path_array_guess_` is #testpoint for [tmx] too :(

    class LoadTicket_via_AlreadyLoaded < MonadicMagneticAndModel_

      include LoadTicketMethods__

      # if you need a load ticket but already have a sidesystem loaded, life is easier

      def initialize ss_mod
        @gem_name_elements = Models::GemNameElements::Via_AlreadyLoaded[ ss_mod ]
        # can't freeze - makes things lazily
      end

      def _const_path_array_guess_
        @gem_name_elements.const_head_path
      end
    end

    # ==

    class LoadTicket ; include LoadTicketMethods__

      def initialize gne  # GemNameElements

        @require_path = gne.gem_name.gsub DASH_, ::File::SEPARATOR
        @gem_name_elements = gne
        __init_const_path_array_guess
      end

      def __init_const_path_array_guess

        # (see [#030.1] re: a gem name many segments, segment is many pieces)

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

        @_const_path_array_guess_ = const_path_guess.freeze ; nil
      end

      def require_sidesystem_module
        @____sidesys_mod ||= __induce_sidesystem_module
      end

      def __induce_sidesystem_module  # #testpoint

        require @require_path

        # we avoid using `const_reduce` (for name correction) unless we
        # need to (for no good reason).
        # this is near but not the same as a [#063.1] mountable one-off

        mod = ::Object
        sym_a = _const_path_array_guess_
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

      attr_reader(
        :_const_path_array_guess_,
        :require_path,
      )
    end

    # ==

    module LoadTicketMethods__

      # --

      def to_one_off_scanner_via_filesystem fs
        to_one_off_scanner_by do |o|
          o.filesystem = fs
        end
      end

      def to_one_off_scanner_by
        Home_::Magnetics_::OneOffScanner_via_LoadTicket.call_by do |o|
          o.entry_glob = ONE_OFF_ENTRY_GLOB___
          o.filesystem = ::Dir
          yield o
          o.load_ticket = self
        end
      end

      # --

      def one_off_const_head
        @___one_off_const_head ||= __one_off_const_head
      end

      def __one_off_const_head

        cp = _const_path_array_guess_
        if ALL_CAPS___ =~ cp.last  # see #here-1
          cp.last.id2name.freeze
        else
          s = entry_string
          "#{ s[0].upcase }#{ s[1..-1] }".freeze
        end
      end

      def slug
        @___slug ||= entry_string.gsub( UNDERSCORE_, DASH_ ).freeze
      end

      def intern
        @___as_intern ||= entry_string.intern
      end

      # --

      def entry_string
        @gem_name_elements.entry_string
      end

      def gem_path
        @gem_name_elements.gem_path
      end

      # --

      attr_reader(
        :gem_name_elements,
      )

      def IS_LOAD_TICKET_tmx_  # temporary
        true
      end
    end


    # ==

    # ==

    # see #tombstone-C in other file, was #wish [#co-067]

    Const_guess_via_segment___ = -> do
      work = -> segment do
        segment.split( UNDERSCORE_ ).map do |piece|
          LoadTicket::Const_guess_via_piece[ piece ]
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

    LoadTicket::Const_guess_via_piece = -> do

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
          # save the trouble - if it's not a TLA or a FLA, it should not be an acronym
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

    LoadTicket_via_AlreadyLoaded::Const_guess_via_piece =
      LoadTicket::Const_guess_via_piece

    # ==

    ALL_CAPS___ = /\A[A-Z0-9_]+\z/
    ONE_OFF_ENTRY_GLOB___ = 'tmx-*'  # don't pickup special ones like `git-stash-untracked`

    # ==
  end
end
# #history: moved from [tmx] to [ze]
# #history: broke out from "installation" model
