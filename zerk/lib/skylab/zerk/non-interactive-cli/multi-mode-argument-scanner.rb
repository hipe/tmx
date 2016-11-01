module Skylab::Zerk

  class NonInteractiveCLI

    class MultiModeArgumentScanner < Home_::ArgumentScanner::CommonImplementation

      # currently the "flagship" (more complex) argument scanner
      # implementation. (general introduction and notes at [#052].)

      # ([#bs-028].F `_this_method_name_convention_` is employed heavily.)

      class << self
        def define
          bld = Builder___.new
          o = DSL___.new bld
          yield o
          bld.finish
        end
        alias_method :__new_multi_mode_argument_scanner, :new
        undef_method :new
      end  # >>

      # ==

      class DSL___

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

        def add_primary sym
          $stderr.puts "IGNORING ADD PRIMARY FOR NW"  # #WHEN:`add_primary`
          ACHIEVED_
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
          @_subtracted_h = nil
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
          @_mid_scanner_pairs.push Common_::Pair.via_value_and_name( x, sym )
          receive_subtract_primary_without_argument sym
          NIL
        end

        def receive_subtract_primary_without_argument sym
          ( @_subtracted_h ||= {} )[ sym ] = true
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

          if msp
            a.push FixedPrimaries___.new msp
          end

          us = remove_instance_variable :@_user_scanner
          if ! us.no_unparsed_exists

            if @_has_default_primary
              _dp_kn = Common_::Known_Known[ @_default_primary_symbol ]
            end

            a.push UserScanner___.new @_subtracted_h, us, _dp_kn, @_listener
          end

          if a.length.zero?
            self._COVER_ME_you_should_result_in_a_singleton_that_says :no_unparsed_exists
          else
            Here_.__new_multi_mode_argument_scanner a, @_listener
          end
        end
      end

      # ==

      Here_ = self
      class Here_

        def initialize a, l
          @listener = l
          @_scn_scn = Common_::Polymorphic_Stream.via_array a
          @_scn = @_scn_scn.gets_one
        end

        def pair_via_match_head_against_primaries_hash_ h

          o = Home_::ArgumentScanner::
              Magnetics::FormalPrimary_via_PrimariesHash.begin h, self

          o.well_formed_potential_primary_symbol_knownness = @_scn._well_formed_knownness_

          if o.is_well_formed

            o.route_knownness = @_scn._route_knownness_via_request_ o.formal_primary_request

            if o.route_was_found

              o.to_common_pair_about_route_that_was_found
            else
              o.whine_about_how_route_was_not_found
            end
          else
            o.whine_about_how_it_is_not_well_formed
          end
        end

        def head_as_well_formed_potential_primary_symbol_  # #feature-island, probably

          o = Home_::ArgumentScanner::
              Magnetics::FormalPrimary_via_PrimariesHash.begin NOTHING_, self

          o.well_formed_potential_primary_symbol_knownness = @_scn._well_formed_knownness_

          if o.is_well_formed

            o.formal_primary_request.well_formed_symbol

          else
            o.whine_about_how_it_is_not_well_formed
          end
        end

        def available_primary_name_stream_via_hash h
          @_scn._available_primary_name_stream_via_hash_ h
        end

        def head_as_normal_symbol
          @_scn._head_as_normal_symbol_
        end

        def head_as_is
          @_scn._head_as_is_
        end

        def advance_one
          @_scn._advance_one_
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

        attr_reader(
          :listener,
          :no_unparsed_exists,
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

        def _well_formed_knownness_
          Common_::Known_Known[ _head ]
        end

        def _head_as_normal_symbol_
          _head
        end

        def _head_as_is_
          _head
        end

        def _head
          @_real_scn.current_token
        end

        def _advance_one_
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
          @_real_scn = Common_::Polymorphic_Stream.via_array mid_scanner_pairs
        end

        def _route_knownness_via_request_ req
          # assume our immediately following method resulted in a known known.
          Common_::Known_Known[ req.primaries_hash.fetch req.well_formed_symbol ]
        end

        def _well_formed_knownness_
          if @_is_pointing_at_name
            Common_::Known_Known[ @_real_scn.current_token.name_x ]
          else
            self._IF_EVER_THEN_WHY
          end
        end

        def _head_as_normal_symbol_
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

        def _head_as_is_
          if @_is_pointing_at_name
            @_real_scn.current_token.name_x
          else
            @_real_scn.current_token.value_x
          end
        end

        def _advance_one_
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
        )
      end

      # ==

      class UserScanner___

        # this is the workhorse parser implementation - the one that
        # translates CLI-shaped arguments to API-shaped ones.

        def initialize h, user_scn, dp_kn, listener

          if dp_kn
            @_default_primary_was_read = false
            @__default_primary_symbol = dp_kn.value_x
            @_has_default_primary = true
          else
            @_has_default_primary = false
          end

          @_is_subtracted = h || MONADIC_EMPTINESS_
          @_listener = listener
          @_real_scn = user_scn
        end

        def _route_knownness_via_request_ req

          # assume our immediately following method resulted in a known
          # known. as such we don't need to check subtracted here.

          user_x = req.primaries_hash[ req.well_formed_symbol ]
          if user_x
            Common_::Known_Known[ user_x ]
          else
            _known_unknown_with_reason :unknown_primary
          end
        end

        def _well_formed_knownness_

          s = @_real_scn.current_token

          if DASH_BYTE_ == s.getbyte(0)  # must begin with one dash

            _d = DASH_BYTE_ == s.getbyte(1) ? 2 : 1

            # for now, if it begins with at least two dashes,
            # treat it exactly the same as if one

            sym = s[ _d .. -1 ].gsub( DASH_, UNDERSCORE_ ).intern

            if @_is_subtracted[ sym ]

              # for now we do the check of "subtracted" here at not at the
              # latter step only so that subtraction *would be* reflected
              # in the old-style of parsing (not with hashes)

              _known_unknown_with_reason :subtracted_primary_was_referenced
            else
              Common_::Known_Known[ sym ]
            end

          elsif @_has_default_primary
            @_default_primary_was_read = true
            Common_::Known_Known[ @__default_primary_symbol ]

          else
            _known_unknown_with_reason :primary_had_poor_surface_form
          end
        end

        def _head_as_normal_symbol_

          # for example the name of a report (in tmx reports)

          s = @_real_scn.current_token
          if DASH_BYTE_ == s.getbyte( 0 )
            self._COVER_ME_design_me
          end

          Ultra_normalize___[ s ]
        end

        def _known_unknown_with_reason sym
          Home_::ArgumentScanner::Known_unknown_with_reason[ sym ]
        end

        def _available_primary_name_stream_via_hash_ h

          is_subtracted = @_is_subtracted

          st = Stream_.call( h.keys ).map_reduce_by do |sym|

            if is_subtracted[ sym ]
              NOTHING_  # skip
            else
              Common_::Name.via_variegated_symbol sym
            end
          end

          # #WHEN:`add_primary` ..

          st
        end

        def _head_as_is_
          @_real_scn.current_token
        end

        def _advance_one_
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
          :_no_unparsed_exists_,
        )
      end

      # ==

      Ultra_normalize___ = -> do
        p = -> ss do
          abnormal = %r([^_a-z0-9]+)i
          leading_or_trailing_underscores = /\A_+|_+\z/
          one_or_more_underscores = %r(__+)
          p = -> s do
            s = s.gsub abnormal, UNDERSCORE_
            s.gsub! one_or_more_underscores, UNDERSCORE_
            s.gsub! leading_or_trailing_underscores, EMPTY_S_
            s.downcase!
            s.intern
          end
          p[ ss ]
        end
        -> s do
          p[ s ]
        end
      end.call

      # ==
    end
  end
end
