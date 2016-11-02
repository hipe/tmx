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

        def add_primary sym, * p_a, & p
          p_a.push p if block_given?
          @_builder.receive_add_primary p_a, sym
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
          @_added_box = nil
          @_description_proc_for_added_h = nil
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

        def receive_add_primary p_a, sym

          # for now (and don't expect this to stay this way forever
          # necessarily), we can model the definition for an added primary
          # as a set (here, list) of only procs:
          #
          #   - one callback proc for handling the parse
          #     (this proc must be niladic)
          #
          #   - zero or one proc for expressing the primary's description
          #     (this proc if provided must be monadic)
          #
          # given that in the above structural signature the formal procs
          # happen to have arities that are unique to their formal argument,
          # we can allow that the argument procs are provided in any order,
          # using only their arities to infer the intent of the argument.
          #
          # we can furthermore treat any passed block indifferently to a
          # positional argument. all of this together is meant to expose a
          # loose, natural syntax where the user can use the block argument
          # for whichever (if any) purpose "feels better" for the use case.
          #
          # for now (in part) because this is so experimental, we take
          # safeguards to ensure that what is required is provided, and that
          # the procs do not clobber each other.

          box = Common_::Box.new
          p_a.each do |p|
            box.add p.arity, p
          end
          ( @_added_box ||= Common_::Box.new ).add sym, box.remove( 0 )
          p = box.remove( 1 ) { }
          if p
            ( @_description_proc_for_added_h ||= {} )[ sym ] = p
          end
          box.length.zero? or raise ::ArgumentError
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

          shared = Shared___.new @_added_box, @_subtracted_h

          us = remove_instance_variable :@_user_scanner
          if ! us.no_unparsed_exists

            if @_has_default_primary
              _dp_kn = Common_::Known_Known[ @_default_primary_symbol ]
            end

            a.push UserScanner___.new shared, us, _dp_kn, @_listener
          end

          if a.length.zero?
            self._COVER_ME_you_should_result_in_a_singleton_that_says :no_unparsed_exists
          else
            Here_.__new_multi_mode_argument_scanner(
              a, @_description_proc_for_added_h, shared, @_listener )
          end
        end
      end

      # ==

      Here_ = self
      class Here_

        def initialize a, d_h, shared, l
          @_description_proc_for_added_h = d_h
          @listener = l
          @_scn_scn = Common_::Polymorphic_Stream.via_array a
          @_scn = @_scn_scn.gets_one
          @_shared = shared
        end

        # -- reflection (for etc)

        def altered_description_proc_reader_via remote

          # given the description proc reader produced by the remote
          # operation, produce a new reader that includes also those for
          # added primaries. (note we don't take into account subtraction).

          added = @_description_proc_for_added_h
          if added
            -> k do
              added[ k ] || remote[ k ]
            end
          else
            remote
          end
        end

        # --

        def match_primary_route_against_ h

          #  "all about parsing added primaries" ([#052] #note-2) explains it all

          begin
            route = __match_niCLI_route_against h
            route || break
            if route.is_more_backey_than_frontey
              break
            end

            _keep_parsing = route.value.call
            if _keep_parsing  # as described at #scn-coverpoint-1-B

              # NOTE we give the client autonomy over its parsing technique
              # (e.g name-based vs type-based) at this cost: the client MUST
              # `advance_one` the scanner herself. if she does not we infinite
              # loop here.

              redo
            end

            route = _keep_parsing  # as described at #scn-coverpoint-1-A
            break
          end while above

          route
        end

        def __match_niCLI_route_against h

          o = Home_::ArgumentScanner::
              Magnetics::FormalPrimary_via_PrimariesHash.begin h, self

          o.well_formed_potential_primary_symbol_knownness = @_scn._well_formed_knownness_

          if o.is_well_formed

            o.route_knownness = @_scn._route_knownness_via_request_ o.formal_primary_request

            if o.route_was_found

              o.route
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

          altered_primary_normal_symbol_stream_via( Stream_[ h.keys ] ).map_by do |sym|
            Common_::Name.via_variegated_symbol sym
          end
        end

        def altered_primary_normal_symbol_stream_via remote_sym_st

          # given a stream of primary normal symbols as produced by the
          # remote operation, produce a new stream (drawing from the
          # argument stream) that reduces from it any subtracted primaries
          # and concats to it the stream symbols for any added primaries.

          shared = @_shared

          sub_h = shared.subtracted_hash
          reduced_st = if sub_h
            remote_sym_st.reduce_by do |sym|
              ! sub_h[ sym ]
            end
          else
            remote_sym_st
          end

          added_box = shared.added_box
          if added_box
            reduced_st.concat_by added_box.to_name_stream
          else
            reduced_st
          end
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

          k = req.well_formed_symbol
          _x = req.primaries_hash.fetch k
          Common_::Known_Known[ DefaultedBasedRoute___.new _x, k ]
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

        def initialize shared, user_scn, dp_kn, listener

          if dp_kn
            @_default_primary_was_read = false
            @__default_primary_symbol = dp_kn.value_x
            @_has_default_primary = true
          else
            @_has_default_primary = false
          end

          bx = shared.added_box
          if bx
            @_has_added = true
            @_added_box = bx
          else
            @_has_added = false
          end

          @__is_subtracted = shared.subtracted_hash || MONADIC_EMPTINESS_
          @_listener = listener
          @_real_scn = user_scn
        end

        def _route_knownness_via_request_ req

          # assume our immediately following method resulted in a known
          # known. as such we don't need to check subtracted here.

          route = __search_for_route_via_exact_match req
          if route
            Common_::Known_Known[ route ]
          else
            __lookup_route_with_fuzzy_match req
          end
        end

        def __search_for_route_via_exact_match req

          k = req.well_formed_symbol
          # -- do we have a primary by this exact name (as normal or as added?)

          if @_has_added
            x = @_added_box[ k ]
          end
          if x
            AddedBasedRoute___.new x, k
          else
            x = req.primaries_hash[ k ]
            if x
              PrimaryHashValueBasedRoute___.new x, k
            end
          end
        end

        def __lookup_route_with_fuzzy_match req  # result in a knownness

          a = nil
          sym = req.well_formed_symbol
          rx = /\A#{ ::Regexp.escape sym }/

          if @_has_added
            @_added_box.each_pair do |k, x|
              rx =~ k || next
              ( a ||= [] ).push AddedBasedRoute___.new( x, k )
            end
          end

          req.primaries_hash.each_pair do |k, x|
            rx =~ k || next
            ( a ||= [] ).push PrimaryHashValueBasedRoute___.new( x, k )
          end

          if a
            if 1 == a.length
              Common_::Known_Known[ a.fetch 0 ]
            else
              Known_unknown_when_ambiguous___[ a, sym ]
            end
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

            if @__is_subtracted[ sym ]

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
          Home_::ArgumentScanner::Known_unknown_via_reason_symbol[ sym ]
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

      Known_unknown_when_ambiguous___ = -> a, k do

        _reasoning = Home_::ArgumentScanner::Reasoning.new do |emit|

          emit.call :error, :expression, :parse_error, :ambiguous do |y|

            cheap = -> sym do
              "\"-#{ sym.id2name.gsub UNDERSCORE_, DASH_ }\""
            end

            y << "ambiguous primary #{ cheap[ k ] }."

            buffer = "did you mean "

            Stream_[ a ].join_into_with_by buffer, " or " do |route|
              cheap[ route.primary_normal_symbol ]
            end

            buffer << "?"

            y << buffer
          end

          UNABLE_
        end

        Common_::Known_Unknown.via_reasoning _reasoning
      end

      # ==

      base = Home_::ArgumentScanner::Route

      class AddedBasedRoute___ < base
        def route_category_symbol
          :route_that_is_added_based
        end
        def is_more_backey_than_frontey
          false
        end
      end

      class DefaultedBasedRoute___ < base
        def route_category_symbol
          :route_that_is_defaulted_based
        end
        def is_more_backey_than_frontey
          true
        end
      end

      PrimaryHashValueBasedRoute___ = Home_::ArgumentScanner::PrimaryHashValueBasedRoute

      # ==

      Shared___ = ::Struct.new :added_box, :subtracted_hash

      # ==
    end
  end
end
