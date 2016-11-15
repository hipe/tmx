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
          @_DP_kn_kn = nil
          @_front_tokens = nil
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
          @_DP_kn_kn = Common_::Known_Known[ sym ]
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

          itemer = Itemer___.new @_added_box, @_subtracted_h

          a = []
          ft = remove_instance_variable :@_front_tokens
          if ft
            a.push FrontTokens__.new ft, itemer
          end

          msp = remove_instance_variable :@_mid_scanner_pairs

          if msp
            a.push FixedPrimaries___.new msp
          end

          us = remove_instance_variable :@_user_scanner
          if ! us.no_unparsed_exists

            a.push UserScanner___.new us, @_DP_kn_kn, itemer, @_listener
          end

          if a.length.zero?
            self._COVER_ME_you_should_result_in_a_singleton_that_says :no_unparsed_exists
          else
            Here_.__new_multi_mode_argument_scanner(
              a, @_description_proc_for_added_h, itemer, @_listener )
          end
        end
      end

      # ==

      Here_ = self
      class Here_

        def initialize a, d_h, itemer, l
          @_description_proc_for_added_h = d_h
          @listener = l
          @on_first_branch_item_not_found = nil
          @no_unparsed_exists = false
          @_itemer = itemer
          @_scn_scn = Common_::Polymorphic_Stream.via_array a
          @_scn = @_scn_scn.gets_one
        end

        # -- run-time mutation

        def insert_at_head * x_a

          # hack that says "whatever you're doing, do this instead".
          # this hack is certain to break for certain cases

          scn = FrontTokens__.new x_a, @_itemer

          if @no_unparsed_exists
            @no_unparsed_exists = false
            @_scn_scn = Common_::Polymorphic_Stream.the_empty_polymorphic_stream
            @_scn = scn
          else
            @_scn_scn.current_index -= 1  # walk back the current scanner
            @_scn = scn
          end

          NIL
        end

        def on_first_branch_item_not_found & p
          @on_first_branch_item_not_found = p ; nil
        end

        def add_primary_at_position d, sym, do_by, desc_by

          @_description_proc_for_added_h[ sym ] = desc_by
          @_itemer.__late_add_ d, sym, do_by
          NIL
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

        def match_branch * a  # MUST set @current_primary_symbol as appropriate

          # "all about parsing added primaries" ([#052] #note-2) explains it all

          o = _begin_match_branch a

          if @on_first_branch_item_not_found
            @_has_relevant_default = true
            @__relevant_default = @on_first_branch_item_not_found
            @on_first_branch_item_not_found = nil
          else
            @_has_relevant_default = false
          end

          begin
            x = __match_niCLI_item_against o
            x || break

            if x.is_the_no_op_branch_item
              redo
            end

            item = x

            @current_primary_symbol = item.branch_item_normal_symbol

            if item.is_more_backey_than_frontey
              break  # "backey" item is found - done.
            end

            x = item.value.call
            if ! x  # custom frontend proc interrupts flow #scn-coverpoint-1-A
              break
            end

            if ! @no_unparsed_exists
              redo  # NOTE if client did not advance scanner herself, infinite loop
            end

            # EEK - when we reach the end of the argument scanner and we
            # ended on a "frontey" primary, then it's hard to hide the
            # existence of this hack completely from the backend. we are
            # in effect trying to tell the backend "we did not fail, but
            # this is not a item." experimental :#scn-note-1 :#here
            # #not-covered - hits IFF `-verbose` at end

            x = The_no_op_item__[]
            break
          end while above

          if x && o.request.do_result_in_value
            x = x.value
          end

          x
        end

        def __match_niCLI_item_against o

          if @no_unparsed_exists
            if @_has_relevant_default
              _use_relevant_default
            else
              o.whine_about_how_argument_scanner_ended_early
            end
          else
            __match_niCLI_item_normally o
          end
        end

        def __match_niCLI_item_normally o

          case o.request.shape_symbol
          when :primary
            m1 = :_well_formed_primary_knownness_
            m2 = :_primary_branch_item_knownness_via_facilitator_
          when :business_item
            m1 = :_well_formed_business_item_knownness_
            m2 = :_business_item_knownness_via_facilitator_
          end

          o.well_formed_potential_symbol_knownness = @_scn.send m1

          if o.is_well_formed

            o.item_knownness = @_scn.send m2, o

            if o.item_was_found
              o.item

            elsif @_has_relevant_default
              _use_relevant_default

            elsif o.request.be_passive
              NOTHING_

            else
              o.whine_about_how_item_was_not_found
            end

          elsif @_has_relevant_default
            _use_relevant_default
          else
            o.whine_about_how_it_is_not_well_formed
          end
        end

        def _use_relevant_default
          _p = remove_instance_variable :@__relevant_default
          @_has_relevant_default = false
          _p[ self ]  # you better work
          _ = The_no_op_item__[]
          _  # #todo
        end

        def head_as_well_formed_potential_primary_symbol_  # #feature-island, probably

          o = _begin_match_branch [ :primary ]

          o.well_formed_potential_symbol_knownness = @_scn._well_formed_primary_knownness_

          if o.is_well_formed

            o.well_formed_symbol

          else
            o.whine_about_how_it_is_not_well_formed
          end
        end

        def _begin_match_branch a

          o = Home_::ArgumentScanner::Magnetics::
              BranchItem_via_OperatorBranch.begin a, Request___[]

          o.receive_argument_scanner self
          o
        end

        # ~(

        Request___ = Lazy_.call do

          class Request____ < Home_::ArgumentScanner::Magnetics::
              BranchItem_via_OperatorBranch::Request

            o = superclass.const_get( :HASH, false ).dup
            o[ :exactly ] = :__at_exactly
            o[ :passively ] = :__at_passively
            HASH = o

            def initialize( * )
              @do_fuzzy_lookup = true
              super
            end

            def __at_exactly
              @_arglist_.advance_one
              @do_fuzzy_lookup = false
            end

            def __at_passively
              @_arglist_.advance_one
              @be_passive = true
            end

            attr_reader(
              :be_passive,
              :do_fuzzy_lookup,
            )

            self
          end
        end

        # )~

        # --

        def available_branch_item_name_stream_via_operator_branch ob, shape_sym
          send THESE_3__.fetch( shape_sym ), ob
        end

        THESE_3__ = {
          business_item: :__available_etc,
          primary: :__available_primary_name_stream_via_operator_branch,
        }

        def __available_primary_name_stream_via_operator_branch ob

          _st = ob.to_normal_symbol_stream do |sym|
            [ :primary, sym ]
          end

          altered_normal_tuple_stream_via( _st ).map_by do |tuple|
            Common_::Name.via_variegated_symbol tuple.fetch 1
          end
        end

        def __available_etc h
          Stream_.call h.keys do |sym|
            Common_::Name.via_variegated_symbol sym
          end
        end

        # --

        def altered_normal_tuple_stream_via remote_normal_tuple_st

          # given a stream of primary normal symbols as produced by the
          # remote operation, produce a new stream (drawing from the
          # argument stream) that reduces from it any subtracted primaries
          # and concats to it the stream symbols for any added primaries.

          itr = @_itemer

          sub_h = itr.subtracted_hash
          reduced_st = if sub_h
            remote_normal_tuple_st.reduce_by do |tuple|
              ! sub_h[ tuple.fetch(1) ]
            end
          else
            remote_normal_tuple_st
          end

          if itr.has_addeds

            _ = itr.addeds_as_operator_branchish.to_normal_symbol_stream do |sym|
              [ :primary, sym ]
            end

            reduced_st.concat_stream _
          else
            reduced_st
          end
        end

        def added_primary_normal_name_symbols
          @_itemer.__added_primary_normal_name_symbols_
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

      class FrontTokens__

        # these (if present) must be an array of symbols. they are merely
        # for indicating to the backend API which operation we are trying
        # to reach, or other hacks.

        def initialize front_tokens, itemer

          @_real_scn = Common_::Polymorphic_Stream.via_array front_tokens
          @_itemer = itemer
        end

        def _primary_branch_item_knownness_via_facilitator_ o
          @_itemer.primary_branch_item_knownness_via_exact_match o
        end

        def _business_item_knownness_via_facilitator_ o
          @_itemer.business_item_knownness_via_facilitator o
        end

        def _well_formed_business_item_knownness_
          Common_::Known_Known[ _head ]
        end

        def _well_formed_primary_knownness_
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

        def _primary_branch_item_knownness_via_facilitator_ o

          # assume that #here.

          # although we have a name-value pair, we are only resulting in
          # a derivative of the name (nothing of the value) here.

          k = @_real_scn.current_token.name_x
          k == o.well_formed_symbol || self._SANITY

          _x = o.operator_branch.entry_value k

          _dbi = DefaultedBranchItem___.new _x, k

          Common_::Known_Known[ _dbi ]
        end

        def _well_formed_primary_knownness_
          if @_is_pointing_at_name
            # :#here.
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

      DEFINITION_FOR_THE_METHOD_CALLED_UNKNOWN_BECAUSE__ = -> sym do
        Home_::ArgumentScanner::Known_unknown[ sym ]
      end

      # ==

      class UserScanner___

        # this is the workhorse parser implementation - the one that
        # translates CLI-shaped arguments to API-shaped ones.

        def initialize user_scn, dp_kn, itemer, listener

          if dp_kn
            @_default_primary_was_read = false
            @__default_primary_symbol = dp_kn.value_x
            @_has_default_primary = true
          else
            @_has_default_primary = false
          end

          @__is_subtracted = itemer.subtracted_hash || MONADIC_EMPTINESS_
          @_itemer = itemer
          @_listener = listener
          @_real_scn = user_scn
        end

        def _primary_branch_item_knownness_via_facilitator_ o

          # assume our immediately following method resulted in a known
          # known. as such we don't need to check subtracted here.

          kn = @_itemer.primary_branch_item_knownness_via_exact_match o
          if kn
            kn
          elsif o.request.do_fuzzy_lookup
            __lookup_primary_branch_item_with_fuzzy_match o
          else
            _when_unknown_primary o
          end
        end

        def _business_item_knownness_via_facilitator_ o
          @_itemer.business_item_knownness_via_facilitator o
        end

        def __lookup_primary_branch_item_with_fuzzy_match o  # result in a knownness

          fuz = Fuzz__.new o

          itr = @_itemer
          if itr.has_addeds
            fuz.visit AddedBranchItem__, itr.addeds_as_operator_branchish
          end
          itr = nil

          fuz.visit OperatorBranchEntry__, o.operator_branch

          x = fuz.maybe_finish
          if x
            x
          else
            _when_unknown_primary o
          end
        end

        def _when_unknown_primary o
          if o.request.be_passive
            self._WALK_THRU_WITH_ME
          else
            _unknown_because :unknown_primary
          end
        end

        def _well_formed_primary_knownness_

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

              _unknown_because :subtracted_primary_was_referenced
            else
              Common_::Known_Known[ sym ]
            end

          elsif @_has_default_primary
            @_default_primary_was_read = true
            Common_::Known_Known[ @__default_primary_symbol ]

          else
            _unknown_because :primary_had_poor_surface_form
          end
        end

        def _well_formed_business_item_knownness_  # (rough sketch)

          s = @_real_scn.current_token

          if DASH_BYTE_ == s.getbyte(0)
            Home_::ArgumentScanner::known_because.call do |emit|
              _whine_into_about_primary emit, s
            end
          else
            Common_::Known_Known[ s.gsub( DASH_, UNDERSCORE_ ).intern ]
          end
        end

        def _head_as_normal_symbol_

          # for example the name of a report (in tmx reports)

          s = @_real_scn.current_token
          if DASH_BYTE_ == s.getbyte(0)
            _whine_into_about_primary @_listener, s  # #not-covered
          else
            Ultra_normalize___[ s ]
          end
        end

        def _whine_into_about_primary emit, s
          emit.call :error, :expression, :operator_parse_error do |y|
            y << "looks like primary, must not: #{ s.inspect }"
          end
          UNABLE_
        end

        define_method :_unknown_because, DEFINITION_FOR_THE_METHOD_CALLED_UNKNOWN_BECAUSE__

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

      class Itemer___

        def initialize bx, h

          if bx
            @_addeds_box = bx
            @has_addeds = true
          else
            @has_addeds = false
          end

          @subtracted_hash = h
        end

        def __late_add_ d, sym, do_by

          if @has_addeds
            bx = @_addeds_box
          else
            @has_addeds = true
            bx = Common_::Box.new
            @_addeds_box = bx
          end

          len = bx.length

          if 0 > d
            if -len > d
              d = -len
            end
          elsif len < d
            d = len
          end

          bx.add_at_position d, sym, do_by
          NIL
        end

        def addeds_as_operator_branchish
          @___AaOB ||= Addeds_as_OperatorBranch___.new @_addeds_box
        end

        def primary_branch_item_knownness_via_exact_match o

          k = o.well_formed_symbol

          if @has_addeds
            p = @_addeds_box[ k ]
          end
          if p
            item = AddedBranchItem__.new p, k
          else
            x = o.operator_branch.lookup_softly k
            if x
              item = OperatorBranchEntry__.new x, k
            end
          end

          item && Common_::Known_Known[ item ]
        end

        def business_item_knownness_via_facilitator o

          k = o.well_formed_symbol
          x = o.operator_branch.lookup_softly k
          if x
            Common_::Known_Known[ OperatorBranchEntry__.new( x, k ) ]
          elsif o.request.do_fuzzy_lookup
            __business_item_knownness_fuzzily o
          else
            _when_unknown_business_item o
          end
        end

        def __business_item_knownness_fuzzily o

          fuz = Fuzz__.new o
          fuz.visit OperatorBranchEntry__, o.operator_branch
          kn = fuz.maybe_finish
          if kn
            kn
          else
            _when_unknown_business_item o
          end
        end

        def _when_unknown_business_item o
          if o.request.be_passive
            Common_::KNOWN_UNKNOWN
          else
            __unknown_because :unknown_business_item
          end
        end

        define_method :__unknown_because, DEFINITION_FOR_THE_METHOD_CALLED_UNKNOWN_BECAUSE__

        def __added_primary_normal_name_symbols_
          if @has_addeds
            _ = @_addeds_box.a_
            _  # #todo
          end
        end

        attr_reader(
          :has_addeds,
          :subtracted_hash,
        )
      end

      # ==

      class Addeds_as_OperatorBranch___

        def initialize bx
          @_box = bx
        end

        def to_pair_stream
          @_box.to_pair_stream
        end

        def to_normal_symbol_stream & p
          @_box.to_name_stream( & p )
        end
      end

      # ==

      class Fuzz__

        def initialize o

          sym = o.well_formed_symbol

          @a = nil
          @rx = /\A#{ ::Regexp.escape sym }/
          @symbol = sym
        end

        def visit cls, branchish

          st = branchish.to_pair_stream
          begin
            pair = st.gets
            pair || break
            k = pair.name_symbol
            @rx =~ k || redo
            ( @a ||= [] ).push cls.new( pair.value_x, pair.name_symbol )
            redo
          end while above
          NIL
        end

        def maybe_finish
          if @a
            if 1 == @a.length
              Common_::Known_Known[ @a.fetch 0 ]
            else
              Known_unknown_when_ambiguous___[ @a, @symbol ]
            end
          end
        end
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

            Stream_[ a ].join_into_with_by buffer, " or " do |item|
              cheap[ item.branch_item_normal_symbol ]
            end

            buffer << "?"

            y << buffer
          end

          UNABLE_
        end

        Common_::Known_Unknown.via_reasoning _reasoning
      end

      # ==

      base = Home_::ArgumentScanner::BranchItem

      The_no_op_item__ = Lazy_.call do
        class NoOpBranchItem___
          def is_the_no_op_branch_item  # always for #scn-note-1 #here
            true
          end
          new
        end
      end

      class AddedBranchItem__ < base
        def item_category_symbol
          :item_that_is_added_based
        end
        def is_more_backey_than_frontey
          false
        end
      end

      class DefaultedBranchItem___ < base
        def item_category_symbol
          :item_that_is_defaulted_based
        end
        def is_more_backey_than_frontey
          true
        end
      end

      OperatorBranchEntry__ = Home_::ArgumentScanner::OperatorBranchEntry

      # ==
    end
  end
end
