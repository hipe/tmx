module Skylab::Zerk

  class NonInteractiveCLI

    # ## scope
    #
    # this is being frontiered by [tmx].
    # we would like it possibly to be able to grow to accomodate the other
    # use cases near what is hinted at below.
    #
    # at its design and creation, it was meant to accomodate a CLI syntax
    # that a bit resembles that of the unix `find` command. specifically,
    # this is where we get the term "primary" is from that oft-used (but
    # unexplained) term in the manpage of `find`.
    #
    #
    #
    #
    # ## the design objectives
    #
    # the grand hack here (a proposed solution to a problem we've been solving
    # in various ways for years) is to meet these design objectives:
    #
    #   - allow the ad-hoc syntax of an API operation to be expressed for
    #     CLI in a more-or-less straightforward, regular way token-per-token
    #     so if you become familar with one syntax, learning to use the other
    #     is almost trivial. (the "almost" is the subject of the next points.)
    #
    #   - towards the above, allow the backend API to interpret arguments in
    #     an "API way" when those arguments are represented in a "CLI way".
    #     typically this means converting "primary" names "-like-this" to
    #     names `:like_this` (that is, strings to symbols and the rest), and
    #     perhaps some ad-hoc translations of value terms, typically from
    #     certain string name conventions to symbol name conventions similar
    #     to that example.
    #
    #   - facilitate a sort of blacklist capability where particular primaries
    #     are designated to be non-accessible to the user, and are typically
    #     (although not necessarily) given a semi-hard-coded value instead;
    #     a process all of which should be fully transparent to the user.
    #     (below, primaries like these are referred to as "fixed primaries".)
    #
    #   - facilitate a "front list" capability where the frontend (CLI) can
    #     add (or perhaps unintentionally mask) primaries not recognized by
    #     the back. this facility must be mostly transparent to the back.

    class MultiModeArgumentScanner < Home_::ArgumentScanner::CommonImplementation

      class << self
        def define
          bld = Builder___.new
          o = Definition___.new bld
          yield o
          bld.finish
        end
        alias_method :__new_multi_mode_argument_scanner, :new
        undef_method :new
      end  # >>

      # ==

      class Definition___

        def initialize bld
          @_builder = bld
        end

        def front_scanner_tokens * sym_a
          @_builder.receive_front_scanner_tokens sym_a
        end

        def subtract_primary sym, * x_a
          if x_a.length.zero?
            @_builder.receive_subtract_primary_without_argument sym
          else
            @_builder.receive_subtract_primary_with_argument sym, * x_a
          end
        end

        def default_primary sym
          @_builder.receive_default_primary sym
        end

        def user_scanner scn
          @_builder.receive_user_scanner scn
        end

        def listener x
          @_builder.receive_listener x
        end
      end

      # ==

      class Builder___

        def initialize
          @_front_tokens = nil
          @_has_default_primary = false
          @_listener = nil
          @_mid_scanner_pairs = nil
          @_subtracted = {}
          # --
          @_receive_default_primary = :__receive_default_primary
          @_receive_front_scanner_tokens = :__receive_front_scanner_tokens
          @_receive_user_scanner = :__receive_user_scanner
        end

        def receive_front_scanner_tokens sym_a
          send @_receive_front_scanner_tokens, sym_a
        end

        def __receive_front_scanner_tokens sym_a
          @_receive_front_scanner_tokens = :_CLOSED_
          @_front_tokens = sym_a
          NIL
        end

        def receive_subtract_primary_with_argument sym, x
          ( @_mid_scanner_pairs ||= [] )
          @_subtracted[ sym ] = true
          @_mid_scanner_pairs.push Common_::Pair.via_value_and_name( x, sym )
          NIL
        end

        def receive_subtract_primary_without_argument sym
          @_subtracted[ sym ] = true
          NIL
        end

        def receive_default_primary sym
          send @_receive_default_primary, sym
        end

        def __receive_default_primary sym
          @_receive_default_primary = :_CLOSED_
          @_has_default_primary = true
          @_default_primary_symbol = sym
          NIL
        end

        def receive_user_scanner scn
          send @_receive_user_scanner, scn
        end

        def __receive_user_scanner scn
          @_receive_user_scanner = :_CLOSED_
          @_user_scanner = scn
          NIL
        end

        def receive_listener x
          @_listener = x ; nil
        end

        def finish

          a = []
          ft = remove_instance_variable :@_front_tokens
          if ft
            a.push FrontTokens___.new ft
          end

          msp = remove_instance_variable :@_mid_scanner_pairs
          sub = remove_instance_variable :@_subtracted
          sub.freeze

          if msp
            a.push FixedPrimaries___.new msp
          end

          us = remove_instance_variable :@_user_scanner
          if ! us.no_unparsed_exists

            if @_has_default_primary
              _dp_kn = Common_::Known_Known[ @_default_primary_symbol ]
            end

            a.push UserScanner___.new sub, us, _dp_kn, @_listener
          end

          if a.length.zero?
            self._COVER_ME_you_should_result_in_a_singleton_that_says :no_unparsed_exists
          else
            Here_.__new_multi_mode_argument_scanner a, sub, @_listener
          end
        end
      end

      # ==

      Here_ = self
      class Here_

        def initialize a, h, l
          @listener = l
          @_scn_scn = Common_::Polymorphic_Stream.via_array a
          @_scn = @_scn_scn.gets_one
          @subtraction_hash = h
        end

        def pair_via_match_head_against_primaries_hash_ h
          _begin_formal_primary_parser.flush_to_pair_via_primaries_hash h
        end

        def head_as_primary_symbol_
          _begin_formal_primary_parser.flush_to_primary_symbol
        end

        def head_as_normal_symbol
          @_scn.head_as_normal_symbol_
        end

        def head_as_strange_name
          @_scn.head_as_strange_name_
        end

        def current_token_as_is
          @_scn.head_as_is_
        end

        def advance_one
          @_scn.advance_one_
          if @_scn._no_unparsed_exists_
            if @_scn_scn.no_unparsed_exists
              remove_instance_variable :@_scn_scn
              remove_instance_variable :@_scn
              @no_unparsed_exists = true
            else
              @_scn = @_scn_scn.gets_one
            end
          end
          NIL
        end

        def _begin_formal_primary_parser

          o = Home_::ArgumentScanner::Magnetics::FormalPrimary_via.begin(
            @_scn._knownness_of_head_as_primary_by_,
            self,
          )
          o.subtraction_hash = @subtraction_hash
          o
        end

        attr_reader(
          :current_primary_symbol,
          :listener,
          :no_unparsed_exists,
          :subtraction_hash,
        )
      end

      # ==

      class FrontTokens___

        # these (if present) must be an array of symbols. they are merely
        # for indicating to the backend API which operation we are trying
        # to reach.

        def initialize front_tokens
          @_real_scn = Common_::Polymorphic_Stream.via_array front_tokens
        end

        def head_as_strange_name_
          Common_::Name.via_variegated_symbol @_real_scn.current_token
        end

        def head_as_normal_symbol_
          @_real_scn.current_token
        end

        def head_as_is_
          @_real_scn.current_token
        end

        def advance_one_
          @_real_scn.advance_one
          @_no_unparsed_exists_ = @_real_scn.no_unparsed_exists ; nil
        end

        attr_reader(
          :_no_unparsed_exists_,
        )
      end

      # ==

      class FixedPrimaries___

        # these are for implementing the other side of "subtraction"
        # (and perhaps one day defaults).

        def initialize mid_scanner_pairs

          @_is_pointing_at_name = true
          @_knownness_of_head_as_primary_by_ = method :__knownness_of_head_as_primary
          @_real_scn = Common_::Polymorphic_Stream.via_array mid_scanner_pairs
        end

        def __knownness_of_head_as_primary
          if @_is_pointing_at_name
            Common_::Known_Known[ @_real_scn.current_token.name_x ]
          else
            self._IF_EVER_THEN_WHY
          end
        end

        def head_as_strange_name_
          _sym = head_as_normal_symbol_
          _ = Common_::Name.via_variegated_symbol _sym
          _  # #todo
        end

        def head_as_normal_symbol_
          if @_is_pointing_at_name
            @_real_scn.current_token.name_x
          else
            x = @_real_scn.current_token.value_x
            if ! x.respond_to? :id2name
              self._IF_EVER_THEN_WHY_2
            end
            x
          end
        end

        def head_as_is_
          if @_is_pointing_at_name
            @_real_scn.current_token.name_x
          else
            @_real_scn.current_token.value_x
          end
        end

        def advance_one_
          if @_is_pointing_at_name
            @_is_pointing_at_name = false
          else
            @_real_scn.advance_one
            if @_real_scn.no_unparsed_exists
              remove_instance_variable :@_is_pointing_at_name
              remove_instance_variable :@_real_scn
              @_no_unparsed_exists_ = true
            else
              @_is_pointing_at_name = true
            end
          end
          NIL
        end

        attr_reader(
          :_no_unparsed_exists_,
          :_knownness_of_head_as_primary_by_,
        )
      end

      # ==

      class UserScanner___

        # this is the workhorse internal parser - the one that translates
        # CLI-shaped arguments to API-shaped ones.

        def initialize sub_h, user_scn, dp_kn, listener

          if dp_kn
            @_default_primary_was_read = false
            @__default_primary_symbol = dp_kn.value_x
            @_has_default_primary = true
          else
            @_has_default_primary = false
          end

          @_listener = listener
          @_knownness_of_head_as_primary_by_ = method :__knownness_of_head_as_primary
          @_real_scn = user_scn
          @_subtracted = sub_h
        end

        def __knownness_of_head_as_primary

          s = @_real_scn.current_token
          if DASH_BYTE_ == s.getbyte(0)
            sym = s[ 1..-1 ].gsub( DASH_, UNDERSCORE_ ).intern
            if @_subtracted[ sym ]
              _known_unknown_via_slug :_subtracted_, s
            else
              Common_::Known_Known[ sym ]
            end
          elsif @_has_default_primary
            @_default_primary_was_read = true
            Common_::Known_Known[ @__default_primary_symbol ]
          else
            _known_unknown_via_slug :_malformed_surface_representation_, s
          end
        end

        def _known_unknown_via_slug sym, slug
          Home_::ArgumentScanner::Known_unknown_with_reason[ sym ]
        end

        def head_as_normal_symbol_
          _s = @_real_scn.current_token
          _s.gsub( DASH_, UNDERSCORE_ ).intern
        end

        def head_as_strange_name_
          _s = @_real_scn.current_token
          Common_::Name.via_slug _s
        end

        def head_as_is_
          @_real_scn.current_token
        end

        def advance_one_
          if @_has_default_primary && @_default_primary_was_read
            @_default_primary_was_read = false
          else
            __advance_one_normally
          end
        end

        def __advance_one_normally
          @_real_scn.advance_one
          if @_real_scn.no_unparsed_exists
            @_no_unparsed_exists_ = true
          end
          NIL
        end

        attr_reader(
          :current_primary_symbol,
          :_knownness_of_head_as_primary_by_,
          :_no_unparsed_exists_,
        )
      end

      # ==
    end
  end
end
