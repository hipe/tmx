module Skylab::TMX

  Models = ::Module.new

  module Models::Sigil

    # this node is classified as a "model" for taxonomics and future-
    # proofing. it's really just a functions node for functions that produce
    # a collection of "sigilizations" from a collection of various shapes of
    # sidesystem reflection (as long as it has a "stem").

    class << self

      def via_reflective_sidesystem_array_ a

        _st = Callback_::Stream.via_nonsparse_array a
        via_stemish_stream _st
      end

      def via_stemish_stream x
        o = Index___.new
        o.stemish_stream = x
        o.execute
      end
    end  # >>

    class Anything___

      # encapsulate the internal representation of the full sigilization
      # effort, and create various collection shapes from it on-demand.

      def initialize bx
        @_box = bx
      end

      def to_stream

        # after a performance below we are left with a box keyed to valid
        # sigils, whose each value is an array of "sigilizations". because
        # the below performer (that build the subject object) succeeded, we
        # must assume there is exactly one sigilization per sigil. we don't
        # bother to map that array down to the item until it is requested;

        @_box.to_value_stream.map_by do | a |
          a.fetch 0
        end
      end
    end

    class Index___

      # find the shortest distinct "sigil" for each sidesystem using a
      # variety (3 count) of heuristic strategies to shorten sidesystem names.
      #
      # (this became a #case-study (see tombstone at end))
      #
      # we don't need to resolve conflicts if the client is looking for the
      # sigil of a sidesystem that doesn't conflict after the first pass but
      # we resolve all conflicts anyway because meh.
      #
      # some of the old name for sigil ("medallion") is still used here and
      # is left intact, perhaps because it is useful as a differentiator for
      # a sigil associated with a sidesystem as opposed to one that is not.

      attr_writer(
        :stemish_stream,
      )

      def execute

        @_box = Callback_::Box.new
        @_conflicts = nil

        ___for_the_first_pass_use_the_two_initials_function

        if @_conflicts
          _resolve_conflicts_using :__second_strategy
        end

        if @_conflicts
          _resolve_conflicts_using :__third_strategy
        end

        if @_conflicts
          self._DESIGN_ME
        else
          Anything___.new @_box
        end
      end

      def ___for_the_first_pass_use_the_two_initials_function

        _st = remove_instance_variable :@stemish_stream

        _st.each do | up_x |
          _meda = ___build_medallion_with_two_initials up_x
          __add_medallion _meda
        end
        NIL_
      end

      def ___build_medallion_with_two_initials up_x

        pieces = up_x.stem.split SPLITTER_RX___, 2

        _very_short_string = if 1 == pieces.length
          pieces.first[ 0, 2 ]
        else
          pieces.map { |s| s[ 0 ] }.join EMPTY_S_
        end

        Sigilization___.new _very_short_string, pieces, up_x
      end

      SPLITTER_RX___ = /(?:_|(?=[0-9]))/

      def __add_medallion meda

        a = @_box.touch meda.sigil do
          []
        end
        a.push meda
        if 2 == a.length
          _a_ = ( @_conflicts ||= [] )
          _a_.push meda.sigil
        end
        NIL_
      end

      def __second_strategy very_short_string

        # if the numbers of pieces are the same among all the conflicting
        # medallions, find the first piece that is not the same and use 2
        # letters not one oh my.
        #
        # 'CodeMolester' vs. 'CodeMetrics' => [cmo] [cme]

        meda_a = @_box.fetch very_short_string

        _number_of_distinct_numbers_of_pieces =
          meda_a.reduce( {} ) { |h, o| h[ o.pieces.length ] = nil ; h }.length

        if 1 == _number_of_distinct_numbers_of_pieces

          _number_of_pieces = meda_a.first.pieces.length  # same for all

          is_this_piece_distinct_among_the_medallions = -> d do
            seen = {}
            meda_a.reduce nil do | _, o |
              s = o.pieces.fetch( d )
              if seen[ s ]
                break false
              else
                seen[ s ] = true
                true
              end
            end
          end

          use_this_d = _number_of_pieces.times.reduce nil do | _, d |

            _yes = is_this_piece_distinct_among_the_medallions[ d ]
            if _yes
              break d
            end
          end

          if use_this_d
            ___attempt_second_strategy_on use_this_d, very_short_string
          end
        end
      end

      def ___attempt_second_strategy_on use_d, bad_very_short_string

        meda_a = @_box.fetch bad_very_short_string

        create = -> meda do

          pieces = meda.pieces

          sub_pieces = use_d.times.map do | d |
            pieces.fetch( d )[ 0, 1 ]  # only one letter here
          end

          sub_pieces.push pieces.fetch( use_d )[ 0, 2 ]  # two letters here

          sub_pieces.join EMPTY_S_
        end

        made = []
        ok = true
        seen = {}

        meda_a.each_with_index do | meda, d |

          new_very_short = create[ meda ]

          if seen[ new_very_short ]
            ok = false
            break
          end

          if @_box.has_name new_very_short
            ok = false
            break
          end

          seen[ new_very_short ] = true

          made[ d ] = new_very_short
        end

        if ok

          _accept_new_very_short_strings made, bad_very_short_string
          ACHIEVED_
        else
          UNABLE_
        end
      end

      def __third_strategy bad_very_short_string

        # if the medallion has one piece, use the first three letters of it
        # (we can increase this as needed perhaps). otherwise use the first
        # letter of each piece.

        # 'TMX' vs. 'TanMan' => [tmx] [tm]

        create = -> meda do

          if 1 == meda.pieces.length
            meda.pieces.fetch( 0 )[ 0, 3 ]
          else
            meda.pieces.map{ |s| s[0] }.join EMPTY_S_
          end
        end

        meda_a = @_box.fetch bad_very_short_string

        made = []
        ok = true
        seen = {}

        meda_a.each_with_index do | meda, d |

          new_very_short = create[ meda ]

          if seen[ new_very_short ]
            ok = false
            break
          end

          if bad_very_short_string != new_very_short

            # it's allowable for us to re-produce the original "bad" very
            # short again here by this algorithm and have it be OK because
            # of the check above that we aren't using it more than once.
            # it remains a potentially ambiguous identifier, but the gravity
            # to keep sigils down to 2 chars is stronger than the gravity to
            # avoid ambiguity (by this code).

            if @_box.has_name new_very_short
              ok = false
              break
            end
          end

          seen[ new_very_short ] = true
          made[ d ] = new_very_short
        end

        if ok
          _accept_new_very_short_strings made, bad_very_short_string
          ACHIEVED_
        else
          UNABLE_
        end
      end

      def _resolve_conflicts_using m

        conflicts = @_conflicts

        conflicts.length.times do | d |

          _very_short_string = conflicts.fetch d

          _yes = send m, _very_short_string

          if _yes
            conflicts[ d ] = nil
          end
        end

        conflicts.compact!

        if conflicts.length.zero?
          @_conflicts = nil
        end

        NIL_
      end

      def _accept_new_very_short_strings made, bad_very_short_string

        meda_a = @_box.remove bad_very_short_string

        meda_a.each_with_index do | meda, d |

          new_very_short = made.fetch d

          meda.sigil = new_very_short  # or not mutate etc

          @_box.add new_very_short, [ meda ]  # we gotta keep the structure :/
        end
        NIL_
      end

      class Sigilization___

        def initialize sigil, pieces, up_x

          @pieces = pieces
          @sigil = sigil
          @x = up_x
        end

        attr_writer :sigil

        def stem
          @x.stem
        end

        attr_reader(
          :pieces,
          :sigil,
          :x,
        )
      end
    end
  end
end
# #tombstone: #case-study: de-functionalize a short but unreadable tangle
