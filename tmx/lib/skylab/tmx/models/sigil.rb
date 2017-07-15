module Skylab::TMX

  module Models::Sigil

    # a "sigil" is simply the (so far always) 2- or 3-character wide short
    # name we use to identify (uniquely) a sidesystem within the context of
    # all sidesystems in the tmx ecosystem. for example, the sigil for
    # "common" is "[co]". the sigil for "tmx" is "[tmx]".
    #
    #   - for whatever reason, we always use the brackets ("[]") around
    #     sigil names when they appear in print. (but their internal
    #     representation probably will not have the brackets in the
    #     string/symbol.)
    #
    #   - we would like that the sigils identify the sidesystem uniquely
    #     not just in the context of all sidesystems installed on the
    #     system but rather all sidesystems known to exist in the real
    #     universe for that version of the ecosystem.

    # at a time in the past (#history-B), we were able to derive the
    # "sigilation" entirely algorithmically as discussed #here-1.
    # however this approach had signifcant costs:
    #
    #   - it became hard to make the algorithm match our aesthetics.
    #     every next new name of a sidesystem seemed to require that we
    #     change not just our list of rules but our algorithm so that the
    #     desired sigil(s) would be generated.
    #
    #   - as algorithms had been written to date, they depended what
    #     sidesystems were actually installed

    # this node is classified as a "model" for taxonomics and future-
    # proofing. it's really just a functions node for functions that produce
    # a collection of "sigilizations" from a collection of various shapes of
    # sidesystem reflection (as long as it has a "stem").

    class << self

      def via_reflective_sidesystem_array_ a

        _st = Stream_[ a ]
        via_stemish_stream _st
      end

      def via_stemish_stream x
        Index__.call_by do |o|
          o.stemish_stream = x
        end
      end

      def via_stemish_box bx
        Index__.call_by do |o|
          o.stemish_box = bx
        end
      end
    end  # >>

    # ==

    class Result___

      # encapsulate the internal representation of the full sigilization
      # effort, and create various collection shapes from it on-demand.

      def initialize sigils, d, items
        @items = items
        @length_of_longest_entry_string = d
        @sigils = sigils
        freeze
      end

      def to_stream  # NOTE - allocates new memory each time
        sigils = @sigils ; items = @items
        Common_::Stream.via_times items.length do |d|
          Sigilization___.new sigils.fetch( d ), :_DO_ME_EASY_tmx_, items.fetch( d )
        end
      end

      attr_reader(
        :length_of_longest_entry_string,
      )
    end

    # ==

    class Index__ < Common_::MagneticBySimpleModel

      # find the shortest distinct "sigil" for each sidesystem using a
      # variety of heuristic strategies to shorten sidesystem names.
      #
      # the authoritative reference to our algorithm *is* the `execute`
      # method, which is meant to be readable as pseudocode.
      #
      # (this became a #case-study (see tombstone at end))
      #
      # :#here-1

      def initialize
        @stemish_stream = nil
        super

        @_cha_cha_table = Common_::Box.new
        @_entry_string_via_offset = []
        @_length_of_longest_whatever = 0
        @_multiple_pieces_bucket = []
        @_offset_via_sigil_box = Common_::Box.new
        @_one_piece_bucket = []
        @_pieces_via_offset = []
        @_remote_items = []
      end

      def stemish_box= bx
        @stemish_stream = bx.to_value_stream
        bx
      end

      attr_writer(
        :stemish_stream,
      )

      def execute

        while __next_item
          if __current_thing_ding_is_exactly_two_or_three_characters_long
            __use_that
          elsif __the_thing_ding_has_multiple_pieces
            __put_it_in_the_multiple_pieces_bucket
          else
            __put_it_in_the_one_piece_bucket
          end
        end

        while __next_item_in_the_multiples_bucket
          __use_the_name_derived_from_each_first_character_of_each_piece
        end

        while __next_item_in_the_one_piece_bucket
          __add_it_to_the_cha_cha_table
        end

        __allocate_the_cha_cha_table

        __flush
      end

      def __flush

        remove_instance_variable :@_entry_string_via_offset
        len_etc = remove_instance_variable :@_length_of_longest_whatever
        bx = remove_instance_variable :@_offset_via_sigil_box
        remove_instance_variable :@_pieces_via_offset
        items = remove_instance_variable :@_remote_items

        _a = instance_variables
        if _a.length.nonzero?
          oops
        end

        # as courtesy, expose the sigils in an order that corresponds to
        # the order the original items were received in, not our weird order

        len = items.length
        a = ::Array.new len
        countdown = len

        bx.each_pair do |sigil, d|
          a[ d ] && oops
          a[ d ] = sigil.freeze
          countdown -= 1
        end
        a.freeze
        countdown.zero? || oops

        Result___.new a, len_etc, items
      end

      # -- E.

      def __next_item_in_the_one_piece_bucket
        send ( @_next ||= :__next_one_piece_initially )
      end

      def __next_one_piece_initially
        _etc_for :@_one_piece_bucket
      end

      def __allocate_the_cha_cha_table

        remove_instance_variable( :@_cha_cha_table ).each_pair do |sigil, d_a|

          if 1 == d_a.length
            @_offset_via_sigil_box.add sigil, d_a[0]
            next
          end

          # "task" -> [tas]
          # "tabular" -> [tab]

          d_a.each do |d|
            s_a = @_pieces_via_offset.fetch d
            @_offset_via_sigil_box.add s_a.fetch( 0 )[ 0, 3 ], d
          end
        end

        NIL
      end

      def __add_it_to_the_cha_cha_table

        # what you can assume about the current item:
        #   - its name is not simply a single 2 or 3 length piece
        #   - its name is one piece

        s_a = _current_pieces
        1 == s_a.length || sanity
        3 < s_a.first.length || sanity

        sigil = s_a.first[ 0, 2 ]
        if _this_sigil_is_already_being_used sigil
          sigil = s_a.first[ 0, 3 ]
        end

        @_cha_cha_table.touch_array( sigil ).push @_current_item_offset
        NIL
      end

      def __put_it_in_the_one_piece_bucket
        @_one_piece_bucket.push @_current_item_offset ; nil
      end

      # -- D.

      def __next_item_in_the_multiples_bucket
        send ( @_next ||= :__next_multiple_initially )
      end

      def __next_multiple_initially
        _etc_for :@_multiple_pieces_bucket
      end

      def __use_the_name_derived_from_each_first_character_of_each_piece

        s_a = _current_pieces

        sigil = s_a.reduce "" do |m, piece_s|
          m << piece_s[ 0 ]
        end

        if _this_sigil_is_already_being_used sigil

          # "code_metrics" => [cme]
          # "code_molester" => [cmo] (but it's no longer there)
          # "cm" -> [cm]

          2 == s_a.length || never_been_kissed

          buffer = s_a.fetch(0)[0]
          buffer << s_a.fetch(1)[0,2]
          sigil = buffer
        end

        _use_this_sigil sigil
        NIL_
      end

      def __the_thing_ding_has_multiple_pieces
        1 < _current_pieces.length
      end

      def __put_it_in_the_multiple_pieces_bucket
        @_multiple_pieces_bucket.push @_current_item_offset ; nil
      end

      # -- (nearby shared)

      def _etc_for ivar
        _d_a = remove_instance_variable ivar
        @_current_item_offset = nil
        @_current_etc = Common_::Stream.via_nonsparse_array _d_a
        @_next = :__next_etc_normally
        send @_next
      end

      def __next_etc_normally
        d = @_current_etc.gets
        if d
          @_current_item_offset = d ; true
        else
          remove_instance_variable :@_current_item_offset
          remove_instance_variable :@_current_etc
          remove_instance_variable :@_next ; false
        end
      end

      # -- C.

      def __current_thing_ding_is_exactly_two_or_three_characters_long
        s_a = _current_pieces
        1 == s_a.length and ( 2..3 ).include? s_a.first.length
      end

      def __use_that
        _use_this_sigil _current_entry_string
        NIL_
      end

      def _use_this_sigil sigil
        @_offset_via_sigil_box.add sigil, @_current_item_offset
        NIL
      end

      def _this_sigil_is_already_being_used sigil
        @_offset_via_sigil_box.has_key sigil
      end

      # -- B.

      def __next_item
        send ( @_next_item ||= :__next_item_initially )
      end

      def __next_item_normally
        x = @stemish_stream.gets
        if x
          @_current_item_offset += 1
          @_current_item = x

          s = @_current_item.entry_string.freeze
          len = s.length
          if @_length_of_longest_whatever < len
            @_length_of_longest_whatever = len
          end
          @_entry_string_via_offset.push s

          _s_a = _current_entry_string.split( SPLITTER_RX___ ).freeze
          @_pieces_via_offset.push _s_a
          @_remote_items.push x
          true
        else
          @_remote_items.freeze
          remove_instance_variable :@_next_item
          remove_instance_variable :@_current_item
          remove_instance_variable :@_current_item_offset
          remove_instance_variable :@stemish_stream
          false
        end
      end

      def _current_entry_string
        @_entry_string_via_offset.fetch @_current_item_offset
      end


      SPLITTER_RX___ = /
        _  # split on a plain old underscore
        |
        (?<=\D)(?=\d)  # split on the zero-width space between a not digit and a digit
        |
        (?<=\d)(?=\D)  # split on the zero-width space between a digit and a not digit
      /x

      def __next_item_initially
        @_current_item_offset = -1
        @_current_item = nil
        @_next_item = :__next_item_normally
        send @_next_item
      end

      def _current_pieces
        @_pieces_via_offset.fetch @_current_item_offset
      end
    end

    # ==

    class Sigilization___

      def initialize sigil, pieces, up_x

        @pieces = pieces
        @remote_item = up_x
        @sigil = sigil
        freeze
      end

      def entry_string
        @remote_item.entry_string
      end

      attr_reader(
        :pieces,
        :remote_item,
        :sigil,
      )
    end

    # ==
    # ==
  end
end
# :#history-B: as referenced, near full rewrite
# #tombstone: #case-study: de-functionalize a short but unreadable tangle
