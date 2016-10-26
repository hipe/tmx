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

    class MultiModeArgumentScanner

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

        def match_head_against_primaries_hash h
          Home_::ArgumentScanner::Magnetics::PrimaryNameValue_via_Hash[ self, h ]
        end

        def parse_primary_value * x_a
          parse_primary_value_via_parse_request parse_parse_request x_a
        end

        def parse_parse_request x_a
          Home_::ArgumentScanner::Magnetics::ParseRequest_via_Array[ x_a ]
        end

        def parse_primary_value_via_parse_request req
          Home_::ArgumentScanner::Magnetics::PrimaryValue_via_ParseRequest[ self, req ]
        end

        def head_as_normal_symbol_for_primary
          sym = @_scn.head_as_normal_symbol_for_primary_
          @current_primary_symbol = sym
          sym
        end

        def head_as_normal_symbol
          @_scn.head_as_normal_symbol_
        end

        def head_as_agnostic
          @_scn.head_as_agnostic_
        end

        def current_token_as_is
          @_scn.head_as_is_
        end

        def advance_one
          @_scn.advance_one_
          if @_scn.no_unparsed_exists_
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

        def when_unrecognized_primary ks_p, & emit
          Home_::ArgumentScanner::When::Unrecognized_primary[ self, ks_p, emit ]
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

        def initialize front_tokens
          @_real_scn = Common_::Polymorphic_Stream.via_array front_tokens
        end

        def head_as_agnostic_
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
          @no_unparsed_exists_ = @_real_scn.no_unparsed_exists ; nil
        end

        attr_reader(
          :no_unparsed_exists_,
        )
      end

      # ==

      class FixedPrimaries___

        def initialize mid_scanner_pairs
          @_real_scn = Common_::Polymorphic_Stream.via_array mid_scanner_pairs
          @_is_pointing_at_name = true
        end

        def head_as_normal_symbol_for_primary_
          _head_as_normal_symbol
        end

        def head_as_normal_symbol_
          _head_as_normal_symbol
        end

        def head_as_agnostic_
          _sym = _head_as_normal_symbol
          _ = Common_::Name.via_variegated_symbol _sym
          _  # #todo
        end

        def _head_as_normal_symbol
          if @_is_pointing_at_name
            @_real_scn.current_token.name_x
          else
            x = @_real_scn.current_token.value_x
            if ! x.respond_to? :id2name
              Home_._MAYBE_CHECK_YOUR_VALUE
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
              @no_unparsed_exists_ = true
            else
              @_is_pointing_at_name = true
            end
          end
          NIL
        end

        attr_reader(
          :no_unparsed_exists_,
        )
      end

      # ==

      class UserScanner___

        def initialize sub_h, user_scn, dp_kn, listener

          if dp_kn
            @_default_primary_was_read = false
            @__default_primary_symbol = dp_kn.value_x
            @_has_default_primary = true
          else
            @_has_default_primary = false
          end

          @_listener = listener
          @_real_scn = user_scn
          @_subtracted = sub_h
        end

        def head_as_normal_symbol_for_primary_

          s = @_real_scn.current_token
          if DASH_BYTE_ == s.getbyte(0)
            sym = s[ 1..-1 ].gsub( DASH_, UNDERSCORE_ ).intern
            if @_subtracted[ sym ]
              __when_subtracted_primary_is_referenced
            else
              sym
            end
          elsif @_has_default_primary
            @_default_primary_was_read = true
            @__default_primary_symbol
          else
            __when_does_not_look_like_primary
          end
        end

        def __when_subtracted_primary_is_referenced
          _when_bad_primary :subtracted_primary_referenced
        end

        def __when_does_not_look_like_primary
          _when_bad_primary :unknown_primary_or_operator
        end

        def _when_bad_primary sym
          s = @_real_scn.current_token
          @_listener.call :error, :expression, :parse_error, sym do |y|
            y << "unknown primary: #{ s.inspect }"
          end
          UNABLE_
        end

        def head_as_normal_symbol_
          _s = @_real_scn.current_token
          _s.gsub( DASH_, UNDERSCORE_ ).intern
        end

        def head_as_agnostic_
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
            @no_unparsed_exists_ = true
          end
          NIL
        end

        attr_reader(
          :current_primary_symbol,
          :no_unparsed_exists_,
        )
      end

      # ==
    end
  end
end
