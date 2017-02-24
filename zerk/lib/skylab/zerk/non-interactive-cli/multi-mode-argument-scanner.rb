module Skylab::Zerk

  class NonInteractiveCLI

    class MultiModeArgumentScanner < Home_::ArgumentScanner::CommonImplementation

      # the "flagship" and more complicated of the two argument scanner
      # implementations, this is a compound scanner made up of up to 3
      # kinds of sub-scanners that.. (see [#052] "the multi-mode..")

      # (reminder: we might make use of the obscure name convention of
      # [#bs-028.2.1] (`__this_convention_`).)

      class << self

        def define
          store = ConstraintsAndMutableStore___.new
          yield DSL__.new store
          new( * store.flush_to_array )
        end

        private :new  # #here3
      end  # >>

      # ==

      Oncer__ = -> do  # #note-2

        awful = -1

        -> m, & impl do

          once_m = ( awful += 1 ).to_s.intern
          define_method once_m, & impl

          define_method m do |*a, &p|
            h = @_lockout_
            if h.fetch( m ) { h[ m ] = nil ; true }
              send once_m, * a, & p
            else
              self._CLOSED_
            end
          end
        end
      end

      # ==

      class DSL__

        # (it must be that at least one intermediary between where the
        # defintion is read and when the final front scanner is constructed
        # because, for exampe, sub-scanners typically need to be constructed
        # with the emission listener but the emission listener might be set
        # after the sub-scanners are defined.)

        def initialize store
          @_store = store
        end

        def default_primary sym
          @_store.__receive_default_primary_ sym
        end

        def add_primary sym, * p_a, & p
          p_a.push p if block_given?
          @_store.__receive_add_primary_ sym, p_a
        end

        def subtract_primary sym, * x_a
          if x_a.length.zero?
            @_store.__receive_subtract_primary_without_default_ sym
          else
            @_store.__receive_subtract_primary_with_default_( * x_a, sym )
          end
        end

        def front_scanner_tokens * sym_a, sym
          sym_a.push sym
          @_store.__receive_front_scanner_tokens_ sym_a
        end

        def user_scanner real_scn
          @_store.__receive_user_scanner_ real_scn
        end

        def emit_into p
          @_store.__receive_listener_ p
        end
      end

      # ==

      class ConstraintsAndMutableStore___

        def initialize

          @_initial_front_scanner_tokens = nil
          @_itemer = Itemer___.new
          @_fixed_primary_name_value_pairs_array = nil
          @_listener = nil
          @_lockout_ = {}
          @_real_user_scanner = nil
        end

        define_singleton_method :once, Oncer__[]

        once :flush_to_array do  # #here3
          [
            @_initial_front_scanner_tokens,
            @_itemer,
            @_fixed_primary_name_value_pairs_array,
            @_listener,
            @_real_user_scanner,
          ]
        end

        once :__receive_on_first_branch_item_not_found__ do |p|
          @_on_first_branch_item_not_found = p
        end

        def __receive_default_primary_ sym
          @_itemer.__do_receive_default_primary_ sym
        end

        def __receive_add_primary_ sym, p_a

          # temporarily we can take liberties with the signature .. #note-3

          bx = Common_::Box.new

          p_a.each do |p|
            bx.add p.arity, p
          end

          _action_p = bx.remove 0
          _desc_p = bx.remove( 1 ) { }
          bx.length.zero? || self._ARGUMENT_ERROR

          @_itemer._add_primary_at_position_( -1, sym, _action_p, _desc_p )

          NIL
        end

        def __receive_subtract_primary_with_default_ x, sym

          _ = Common_::Pair.via_value_and_name x, sym

          ( @_fixed_primary_name_value_pairs_array ||= [] ).push _

          @_itemer.subtract_primary sym
        end

        def __receive_subtract_primary_without_default_ sym

          @_itemer.subtract_primary sym
        end

        once :__receive_front_scanner_tokens_ do |sym_a|

          # (locks out only to preserve its historical symantics for now)

          @_initial_front_scanner_tokens = sym_a
        end

        once :__receive_user_scanner_ do |real_scn|
          @_real_user_scanner = real_scn
        end

        once :__receive_listener_ do |p|
          @_listener = p
        end
      end

      # ==

      Here_ = self
      class Here_

        def initialize ifst, itmr, fpnvpa, l, rus  # :#here3

          @listener = l
          @no_unparsed_exists = true

          @_itemer = itmr
          @_first_time_only_match_hook = nil
          @_scanners = Basic_[]::OrderedCollection.begin_empty ComparableScanner___

          # --

          # ~ initial front scanner tokens

          if ifst
            _touch_front_scanner_tokens ifst
          end

          # ~ fixed primary name value pair array

          if fpnvpa
            __init_fixed_primaries_scanner fpnvpa
          end

          # ~ real user scanner (polymorphic scanner)

          if ! rus.no_unparsed_exists
            # this ..
            __init_user_scanner rus
          end
        end

        # -- mutators

        def on_first_branch_item_not_found & p
          @_first_time_only_match_hook = p
        end

        def insert_at_head *sym_a, sym

          # hack that says "whatever you're doing, do this instead".
          # this hack is certain to break for certain cases

          sym_a.push sym
          _touch_front_scanner_tokens sym_a
        end

        def _touch_front_scanner_tokens sym_a  # assume nonzero length

          _insert_or_retrieve_sub_scanner :_front_tokens_,
            -> _k do
              FrontTokens__.new sym_a, @_itemer
            end,
            -> xx do
              ::Kernel._K
            end
          NIL
        end

        def add_primary_at_position d, sym, do_by, desc_by

          @_itemer._add_primary_at_position_ d, sym, do_by, desc_by
          NIL
        end

        def __init_fixed_primaries_scanner pair_a

          _sub_scn = FixedPrimaries___.new pair_a
          _place_sub_scanner :_fixed_primaries_, _sub_scn
          NIL
        end

        def __init_user_scanner real_scn

          _sub_scn = UserScanner___.new real_scn, @_itemer, @listener
          _place_sub_scanner :_user_scanner_, _sub_scn
          NIL
        end

        # --

        def _place_sub_scanner k, x

          @_scanners.insert_or_retrieve( k ) { x }

          @no_unparsed_exists = false

          NIL
        end

        def _insert_or_retrieve_sub_scanner k, p, p_

          @_scanners.insert_or_retrieve k, p, p_

          @no_unparsed_exists = false

          NIL
        end

        # -- READERS

        def match_branch * a  # MUST set @current_primary_symbol as appropriate
          _matcher_via_array( a ).gets
        end

        def head_as_well_formed_potential_primary_symbol_  # #feature-island, probably

          o = matcher_for :primary
          _x  = o.__to_well_formed_symbol_
          _x  # #todo
        end

        def matcher_for * a
          _matcher_via_array a
        end

        def _matcher_via_array a
          Matcher___.new self, a
        end

        def match_integer_
          # 2 defs 1 call. assume nonempty. caller emits IFF result is nil #[#007.5]
          s = head_as_is
          if %r(\A-?\d+\z) =~ s  # ..
            s.to_i
          end
        end

        # --

        def altered_description_proc_reader_via remote

          # given the description proc reader produced by the remote
          # operation, produce a new reader that includes also those for
          # added primaries. (note we don't take into account subtraction).

          h = @_itemer.description_proc_for_addeds_hash
          if h
            -> symbol_or_loadable_reference do
              # when a primary of a remote "mounted" operator, is symbol
              ::Symbol === symbol_or_loadable_reference or self._OK_FINE
              k = symbol_or_loadable_reference  # [#062] might be symbol, might be object
              h[ k ] || remote[ k ]
            end
          else
            remote
          end
        end

        # --

        def available_branch_item_name_stream_via_operator_branch ob, shape_sym
          send THESE_3__.fetch( shape_sym ), ob
        end

        THESE_3__ = {
          business_item: :__available_business_name_stream_via_operation_branch,
          primary: :__available_primary_name_stream_via_operator_branch,
        }

        def __available_primary_name_stream_via_operator_branch ob

          _st = ob.to_loadable_reference_stream.map_by do |key_x|
            [ :primary, key_x ]
          end

          altered_normal_tuple_stream_via( _st ).map_by do |tuple|
            Common_::Name.via_variegated_symbol tuple.fetch 1
          end
        end

        def __available_business_name_stream_via_operation_branch ob

          ob.to_loadable_reference_stream.map_by do |key_x|
            Common_::Name.via_variegated_symbol key_x.intern
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

            _ = itr.addeds_as_operator_branchish.to_loadable_reference_stream.map_by do |key_x|
              [ :primary, key_x ]
            end

            Common_::Stream::CompoundStream.define do |o|
              o.add_stream reduced_st
              o.add_stream _
            end
          else
            reduced_st
          end
        end

        def added_primary_normal_name_symbols
          @_itemer.__added_primary_normal_name_symbols_
        end

        def head_as_normal_symbol
          @_scanners.head_item._head_as_normal_symbol_
        end

        def head_as_is
          @_scanners.head_item._head_as_is_
        end

        def advance_one

          o = @_scanners.head_item
          o._advance_one_
          if o._no_unparsed_exists_

            o = @_scanners
            o.remove_head_comparable
            if o.is_empty

              # #cover-me :[#tmx-016]:
              # this trips only when we run "test-all" in our usual way
              #
              # do not remove :@_scanners here - even though we have reached
              # the end of the scan, the particular outer client
              # implementation may want to customize the call to the remote
              # operation by prepending new tokens to the front of the
              # scanner.

              @no_unparsed_exists = true
            end
          end
          NIL
        end

        # --

        # ~

        def __tick_
          if @_first_time_only_match_hook
            @__relevant_default = @_first_time_only_match_hook
            @_first_time_only_match_hook = nil
            @_has_relevant_default = true
          else
            @_has_relevant_default = false
          end
          NIL
        end

        def __has_relevant_default_
          @_has_relevant_default
        end

        def __release_relevant_default_
          _p = remove_instance_variable :@__relevant_default
          @_has_relevant_default = false
          _p
        end

        # ~

        def __receive_CPS_ sym
          @current_primary_symbol = sym ; nil
        end

        # ~

        def _head_scanner_
          @_scanners.head_item
        end

        # --

        attr_reader(
          :listener,
          :no_unparsed_exists,
        )

        def expression_agent
          # (only for compat with [#007.D] primary value normalization)
          NonInteractiveCLI::ArgumentScannerExpressionAgent.instance
        end
      end

      # ==

      class ComparableScanner___

        def initialize k, item
          @item = item
          @___precedence_integer = ORD__.fetch k
        end

        def compare_against_key k
          @___precedence_integer <=> ORD__.fetch( k )
        end

        attr_reader(
          :item,
        )
      end

      _order = [ :_front_tokens_, :_fixed_primaries_, :_user_scanner_ ]
      ORD__ = ::Hash[ _order.each_with_index.map { |*a| a } ]

      # ==

      class Matcher___

        def initialize as, req_a
          @argument_scanner = as
          @request = Request___[].new req_a
        end

        def gets
          Search___.new( @request, @argument_scanner ).execute
        end

        def __to_well_formed_symbol_
          Search___.new( @request, @argument_scanner ).__do_well_formed_symbol_
        end
      end

      # ==

      class Search___

        # "all about parsing added primaries" [#052] #note-2

        def initialize req, as

          @argument_scanner = as
          @request = req

          @_ = AS_Lib__::Magnetics

          freeze
        end

        def execute

          as = @argument_scanner
          as.__tick_

          begin
            x = __step
            x || break
            if x.is_the_no_op_branch_item
              redo
            end
            item = x

            if item.is_more_backey_than_frontey

              as.__receive_CPS_ item.branch_item_normal_symbol

              break  # "backey" item is found - done.
            end

            x = item.branch_item_value.call
            if ! x  # custom frontend proc interrupts flow #scn-coverpoint-1-A
              break
            end

            if ! as.no_unparsed_exists
              redo  # NOTE if client did not advance scanner infinite loop
            end

            x = The_no_op_item__[]  # EEK #note-4
              #not-covered - hits IFF `-verbose` at end
              #experimental :#scn-note-1 :#here2

            break
          end while above

          if x && @request.do_result_in_value
            x = x.branch_item_value
          end

          x
        end

        def __step

          if @argument_scanner.no_unparsed_exists
            if _has_relevant_default
              _use_relevant_default
            else
              @_.whine_about_how_argument_scanner_ended_early self
            end
          else
            __money_step
          end
        end

        def __money_step

          catzn = _well_formed_categorization

          if catzn.is_well_formed

            catzn = __search_categorization catzn.well_formed_symbol

            if catzn

              if catzn.item_was_found
                catzn.item

              elsif _has_relevant_default
                _use_relevant_default

              else
                catzn.whine_about_how_item_was_not_found self
              end
            else
              @request.be_passive || self._SANITY  # #here4
              NOTHING_
            end

          elsif _has_relevant_default
            _use_relevant_default
          else
            catzn.whine_about_how_it_is_not_well_formed self
          end
        end

        def __do_well_formed_symbol_

          catzn = _well_formed_categorization

          if catzn.is_well_formed

            catzn.well_formed_symbol
          else
            catzn.whine_about_how_it_is_not_well_formed self
          end
        end

        def __search_categorization sym

          _scn = @argument_scanner._head_scanner_
          _wfr = WellFormedRequest___[ sym, @request ]
          _search_catzn = SC___.fetch @request.shape_symbol
          _catzn = _scn.send _search_catzn, _wfr
          _catzn  # #todo
        end

        WellFormedRequest___ = ::Struct.new :well_formed_symbol, :request

        SC___ = {
          business_item: :_business_categorization_via_WFR_,
          primary: :_primary_categorization_via_WFR_,
        }

        def _well_formed_categorization

          _scn = @argument_scanner._head_scanner_
          _well_formed_catzn = WFC___.fetch @request.shape_symbol
          _catzn = _scn.send _well_formed_catzn
          _catzn  # #todo
        end

        WFC___ = {
          business_item: :_well_formed_business_item_categorization_,
          primary: :_well_formed_primary_categorization_,
        }

        def _has_relevant_default
          @argument_scanner.__has_relevant_default_
        end

        def _use_relevant_default
          _p = @argument_scanner.__release_relevant_default_
          _p[]  # you better work
          _ = The_no_op_item__[]
          _  # #todo
        end

        attr_reader(
          :argument_scanner,
          :request,
        )
      end

      # ==

      Request___ = Lazy_.call do

        class Request____ < AS_Lib__::Magnetics::Request_via_Array

          o = superclass.const_get( :HASH, false ).dup
          o[ :exactly ] = :__at_exactly
          o[ :passively ] = :__at_passively
          HASH = o

          def initialize s_a
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

      # ==

      class FrontTokens__

        # these (if present) must be an array of symbols. they are merely
        # for indicating to the backend API which operation we are trying
        # to reach, or other hacks.

        def initialize front_tokens, itemer

          @_itemer = itemer
          @_real_scn = Common_::Scanner.via_array front_tokens
        end

        # --

        # subject's primary responsibility is to present the plain old
        # head token (symbol) of its internal real scanner as a well-formed
        # primary or business item (indifferently). once we get to the point
        # where the below 2 methods are called, subject has alread done that
        # and all that is left to is is pass thru to itemer.

        def _primary_categorization_via_WFR_ wfr
          _sanity wfr
          @_itemer._do_primary_categorization_thru_exact_match_via_WFR_ wfr
        end

        def _business_categorization_via_WFR_ wfr
          _sanity wfr
          @_itemer._do_business_categorization_via_WFR_ wfr
        end

        def _sanity wfr
          wfr.well_formed_symbol == _head || fail
        end

        # --

        def _well_formed_business_item_categorization_
          AS_Lib__::Magnetics::WellFormed_via_WellFormedSymbol[ _head ]
        end

        def _well_formed_primary_categorization_
          AS_Lib__::Magnetics::WellFormed_via_WellFormedSymbol[ _head ]
        end

        def _head_as_normal_symbol_
          _head
        end

        def _head_as_is_
          _head
        end

        def _head
          @_real_scn.head_as_is
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

        def initialize pairs

          @_is_pointing_at_name = true
          @_real_scn = Common_::Scanner.via_array pairs
        end

        def _primary_categorization_via_WFR_ wfr

          # assume that #here1.

          # although we have a name-value pair, we are only resulting in
          # a derivative of the name (nothing of the value) here.

          k = @_real_scn.head_as_is.name_x
          k == wfr.well_formed_symbol || self._SANITY

          _x = wfr.request.operator_branch.dereference k

          _dbi = DefaultedBranchItem___.via_user_value_and_normal_symbol _x, k

          AS_Lib__::Magnetics::ItemFound_via_Item[ _dbi ]
        end

        def _well_formed_primary_categorization_
          if @_is_pointing_at_name
            # :#here1.
            _sym = @_real_scn.head_as_is.name_x
            AS_Lib__::Magnetics::WellFormed_via_WellFormedSymbol[ _sym ]
          else
            self._IF_EVER_THEN_WHY
          end
        end

        def _head_as_normal_symbol_
          if @_is_pointing_at_name
            @_real_scn.head_as_is.name_x
          else
            x = @_real_scn.head_as_is.value_x
            if ! x.respond_to? :id2name
              self._IF_EVER_THEN_WHY_2
            end
            x
          end
        end

        def _head_as_is_
          if @_is_pointing_at_name
            @_real_scn.head_as_is.name_x
          else
            @_real_scn.head_as_is.value_x
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
        AS_Lib__::Magnetics::ItemNotFound_via_ReasoningSymbol[ sym ]
      end

      # ==

      class UserScanner___

        # this is the workhorse parser implementation - the one that
        # translates CLI-shaped arguments to API-shaped ones.

        def initialize user_scn, itemer, listener

          @__is_subtracted = itemer.subtracted_hash || MONADIC_EMPTINESS_
          @_itemer = itemer
          @_listener = listener
          @_payback_the_use_of_default_primary = false
          @_real_scn = user_scn
        end

        def _primary_categorization_via_WFR_ wfr

          # assume our immediately following method resulted in a known
          # known. as such we don't need to check subtracted here.

          catzn = @_itemer._do_primary_categorization_thru_exact_match_via_WFR_ wfr
          if catzn
            catzn
          elsif wfr.request.do_fuzzy_lookup
            __lookup_primary_branch_item_with_fuzzy_match wfr
          else
            _when_unknown_primary wfr
          end
        end

        def _business_categorization_via_WFR_ wfr
          @_itemer._do_business_categorization_via_WFR_ wfr
        end

        def __lookup_primary_branch_item_with_fuzzy_match wfr  # result in a xx

          fuz = Fuzz__.new wfr.well_formed_symbol

          itr = @_itemer
          if itr.has_addeds
            fuz.visit AddedBranchItem__, itr.addeds_as_operator_branchish
          end
          itr = nil

          fuz.visit OperatorBranchItem__, wfr.request.operator_branch

          catzn = fuz.maybe_finish
          if catzn
            catzn
          else
            _when_unknown_primary wfr
          end
        end

        def _when_unknown_primary wfr
          if wfr.request.be_passive
            self._WALK_THRU_WITH_ME
          else
            AS_Lib__::Magnetics::ItemNotFound_via_ReasoningSymbol.call(
              :unknown_primary )
          end
        end

        def _well_formed_primary_categorization_

          s = @_real_scn.head_as_is

          if DASH_BYTE_ == s.getbyte(0)  # must begin with one dash

            _d = DASH_BYTE_ == s.getbyte(1) ? 2 : 1

            # for now, if it begins with at least two dashes,
            # treat it exactly the same as if one

            sym = s[ _d .. -1 ].gsub( DASH_, UNDERSCORE_ ).intern

            if @__is_subtracted[ sym ]

              # for now we do the check of "subtracted" here at not at the
              # latter step only so that subtraction *would be* reflected
              # in the old-style of parsing (not with hashes)

              AS_Lib__::Magnetics::NotWellFormed_via_ReasonSymbol.call(
                :subtracted_primary_was_referenced )
            else
              AS_Lib__::Magnetics::WellFormed_via_WellFormedSymbol[ sym ]
            end

          elsif @_itemer.has_default_primary
            _sym = @_itemer.default_primary_symbol
            @_payback_the_use_of_default_primary = true
            AS_Lib__::Magnetics::WellFormed_via_WellFormedSymbol[ _sym ]

          else
            AS_Lib__::Magnetics::NotWellFormed_via_ReasonSymbol.call(
              :primary_had_poor_surface_form )
          end
        end

        def _well_formed_business_item_categorization_  # (rough sketch)

          s = @_real_scn.head_as_is

          if DASH_BYTE_ == s.getbyte(0)
            AS_Lib__::known_because.call do |emit|
              _whine_into_about_primary emit, s
            end
          else
            _sym = s.gsub( DASH_, UNDERSCORE_ ).intern
            AS_Lib__::Magnetics::WellFormed_via_WellFormedSymbol[ _sym ]
          end
        end

        def _head_as_normal_symbol_

          # for example the name of a report (in tmx reports)

          s = @_real_scn.head_as_is
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

        def _head_as_is_
          @_real_scn.head_as_is
        end

        def _advance_one_

          if @_payback_the_use_of_default_primary
            @_payback_the_use_of_default_primary = false
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

        # called "itemer" because it produces (primary or business) items.
        #
        # a façade that stands in front of the real operator branch,
        # serving lookup requests of it while effecting addeds and removeds.
        #
        # encapsulates the storage of addeds and removeds so that is
        # insulated from any one sub-scanner implementation.

        def initialize
          @has_addeds = false
          @_lockout_ = {}
        end

        define_singleton_method :once, Oncer__[]

        once :__do_receive_default_primary_ do |sym|

          # (hypothetically we could change the default primary mid-scan
          #  but you MUST cover the `default_primary` feature directly
          #  to try such a stunt)

          if sym
            @has_default_primary = true
            @__default_primary_knownness = Common_::Known_Known[ sym ]
          end
        end

        def _add_primary_at_position_ d, sym, do_by, desc_by

          if @has_addeds
            bx = @_addeds_box
          else
            @has_addeds = true
            bx = Common_::Box.new
            @description_proc_for_addeds_hash = {}
            @_addeds_box = bx
          end

          if desc_by
            @description_proc_for_addeds_hash[ sym ] = desc_by
          end

          len = bx.length

          if 0 > d
            if -len > d
              d = -len
            end
          elsif len < d
            d = len
          end

          bx.add_at_offset d, sym, do_by
          NIL
        end

        def subtract_primary sym
          ( @subtracted_hash ||= {} )[ sym ] = true ; nil
        end

        # -- readers

        def addeds_as_operator_branchish
          @___AaOB ||= Addeds_as_OperatorBranch___.new @_addeds_box
        end

        def _do_primary_categorization_thru_exact_match_via_WFR_ wfr

          k = wfr.well_formed_symbol

          if @has_addeds
            p = @_addeds_box[ k ]
          end
          if p
            item = AddedBranchItem__.via_user_value_and_normal_symbol p, k
          else
            trueish_x = wfr.request.operator_branch.lookup_softly k
            if trueish_x
              item = OperatorBranchItem__.via_user_value_and_normal_symbol trueish_x, k
            end
          end

          item && AS_Lib__::Magnetics::ItemFound_via_Item[ item ]
        end

        def _do_business_categorization_via_WFR_ wfr

          req = wfr.request

          k = wfr.well_formed_symbol
          trueish_x = req.operator_branch.lookup_softly k
          if trueish_x
            _item = OperatorBranchItem__.via_user_value_and_normal_symbol trueish_x, k
            AS_Lib__::Magnetics::ItemFound_via_Item[ _item ]
          elsif req.do_fuzzy_lookup
            __business_categorization_fuzzily wfr
          else
            _categorization_when_unknown_business_item wfr
          end
        end

        def __business_categorization_fuzzily wfr

          fuz = Fuzz__.new wfr.well_formed_symbol
          fuz.visit OperatorBranchItem__, wfr.request.operator_branch
          catzn = fuz.maybe_finish
          if catzn
            catzn
          else
            _categorization_when_unknown_business_item wfr
          end
        end

        def _categorization_when_unknown_business_item wfr
          if wfr.request.be_passive
            NOTHING_  # #here4
          else
            DEFINITION_FOR_THE_METHOD_CALLED_UNKNOWN_BECAUSE__[ :unknown_business_item ]
          end
        end

        def __added_primary_normal_name_symbols_
          if @has_addeds
            _ = @_addeds_box.a_
            _  # #todo
          end
        end

        def default_primary_symbol  # assume has default primary
          @__default_primary_knownness.value_x
        end

        attr_reader(
          :description_proc_for_addeds_hash,
          :has_addeds,
          :has_default_primary,
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

        def to_loadable_reference_stream
          @_box.to_key_stream
        end
      end

      # ==

      class Fuzz__

        def initialize well_formed_symbol

          @a = nil
          @rx = /\A#{ ::Regexp.escape well_formed_symbol }/
          @symbol = well_formed_symbol
        end

        def visit cls, branchish

          st = branchish.to_pair_stream
          begin
            pair = st.gets
            pair || break
            k = pair.name_symbol
            @rx =~ k || redo
            ( @a ||= [] ).push(
              cls.via_user_value_and_normal_symbol(
                pair.value_x, pair.name_symbol ) )
            redo
          end while above
          NIL
        end

        def maybe_finish
          if @a
            if 1 == @a.length
              AS_Lib__::Magnetics::ItemFound_via_Item[ @a.fetch 0 ]
            else
              _rsn = Reasoning_when_ambiguous___[ @a, @symbol ]
              AS_Lib__::Magnetics::ItemNotFound_via_Reasoning[ _rsn ]
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

      Reasoning_when_ambiguous___ = -> a, k do

        AS_Lib__::Reasoning.new do |emit|

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
      end

      # ==

      AS_Lib__ = Home_::ArgumentScanner

      base = AS_Lib__::BranchItem

      The_no_op_item__ = Lazy_.call do
        class NoOpBranchItem___
          def is_the_no_op_branch_item  # always for #scn-note-1 #here2
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

      OperatorBranchItem__ = AS_Lib__::OperatorBranchItem
    end
  end
end
