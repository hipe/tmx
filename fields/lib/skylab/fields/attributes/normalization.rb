module Skylab::Fields

  class Attributes

    class Normalization < Common_::MagneticBySimpleModel  # see [#012]

      # (NOTE at the moment this file/node has both the older (oldest)
      # implemention of normalization used in "attributes actor" (2nd half)
      # and the newest one for model-centric zerk microservices. they are
      # near each other to encourage re-use, but the full realization of
      # this dream is harder than it sounds..)

      Normalize_via_Session_with_StaticAttributes = -> sess, & oes_p do

        # (bridge the older-but-still-newish "attribute actor"-style
        # into the file-eponymous node, which starts #here-1)

        attrs = sess.class::ATTRIBUTES
        if attrs

          call_by do |o|
            # -
          idx = attrs.index_
          sidx = idx.static_index_
          o.effectively_defaultants = sidx.effectively_defaultants
          o.ivar_store = sess
          o.lookup = idx.read_association_by_
          o.requireds = sidx.requireds
            # -
            o.listener = oes_p
          end
        else
          ACHIEVED_
        end
      end

      # ==

      class EK < Common_::MagneticBySimpleModel

        # (this is awfully close to operator branches, but with all the
        #  defaulting and required-ness stuff going on, we go it alone.)

        # we just finished writing the massive but ostensibly "complete"
        # [#012] new normalization algorithm in detailed pseudocode.
        #
        # what you see here is an exercise of the greatest OCD ever:
        # a faithful reproduction (to the letter) of that algorithm,
        # driven by three-laws.

        def initialize
          @argument_scanner = nil
          @listener = nil
          yield self
        end

        def entity= ent
          @_current_association = nil
          @_missing_required_associations = nil
          @_receive_missing_reasons = :__receive_missing_reasons_normally
          @_write_current_value = :__write_current_value_entily
          @entity = ent
        end

        def read_by= p
          @_read_current_value = :__read_current_value_simply
          @read_by = p
        end

        def write_by= p
          @_write_current_value = :__write_current_value_simply
          @write_by = p
        end

        attr_writer(
          :argument_scanner,
          :arguments_to_default_proc_by,
          :association_stream,
          :listener,
        )

        def execute

          # (this decision was informed by the assimilation of [#037.1.G])

          if @argument_scanner
            __execute_driven_by_arguments
          else
            __execute_driven_by_associations
          end
        end

        def __execute_driven_by_arguments

          __index_associations

          until __no_more_arguments

            __match_argument_scanner_head_against_associations || break

            __resolve_unsanitized_value_for_this_primary || break

            __maybe_check_clobber || break

            __resolve_sanitized_value_via_unsanitized_value || break

            _maybe_check_required_and_maybe_send
          end

          @_ok && __run_the_remains_of_the_diminishing_pool
          @_ok && __check_if_there_were_any_missing_requireds
        end

        def __execute_driven_by_associations

          ok = true  # watch what happens if there are no associations

          normalize_value = __value_normalizer

          while __gets_association

            existing_kn = __read_current_knownness

            new_kn = normalize_value[ existing_kn ]
            if ! new_kn
              ok = new_kn ; break
            end

            # (it may be that it was not known and still is not known)

            if existing_kn.is_known_known
              if new_kn.is_known_known
                if existing_kn.object_id == new_kn.object_id
                  NOTHING_  # #covered
                else
                  send @_write_current_value, new_kn.value_x
                end
              else
                self._COVER_ME__became_unknown__
              end
            elsif new_kn.is_known_known
              send @_write_current_value, new_kn.value_x  # writes never fail
            end
          end

          if ok && @_missing_required_associations
            @entity._receive_missing_required_associations_ @_missing_required_associations
          else
            ok
          end
        end

        # -- I

        def __check_if_there_were_any_missing_requireds

          h = remove_instance_variable :@_missing_requireds
          if h
            __when_missing_requireds h.keys
          else
            ACHIEVED_
          end
        end

        def __when_missing_requireds miss_sym_a  # (look like #here-2)

          me = self
          @listener.call :error, :missing_required_attributes do
            me.__build_missing_required_event miss_sym_a
          end
          UNABLE_
        end

        def __build_missing_required_event miss_sym_a

          _miss_a = miss_sym_a.map do |k|
            @_association_via_name_symbol.fetch k
          end

          _ev = Home_::Events::Missing.with(

            :reasons, _miss_a,
            # :lemma, :attribute | :parameter | :property | :primary | :field
            :lemma, :parameter,  # #coverpoint-1-2 ("parameters")
            :USE_THIS_EXPRESSION_AGENT_METHOD_TO_DESCRIBE_THE_PARAMETER, :ick_prim,
          )
          # _ev = Home_::Events::Missing.via _miss_a, 'attribute'
          _ev  # hi. #todo
        end

        # -- H

        def __run_the_remains_of_the_diminishing_pool

          __init_diminishing_pool_traversal

          until __no_more_associations_in_diminishing_pool

            if __the_property_store_already_has_an_existent_value
              next
            end

            @_current_sanitized_value = nil  # #not-taking-any-chances
            remove_instance_variable :@_current_sanitized_value

            if _resolve_a_default_value

              NOTHING_  # any resolved default circumvents any normalization

            elsif _has_ad_hoc_normalizer

              if ! __resolve_sanitized_value_via_ad_hoc_normalizer_against_nothing
                break  # normalization failed, so withdraw
              end

            elsif _is_required

              # the value is (effectively) not set in the prop store,
              # there is (effectively) no default, there is no normalizer,
              # and it's required. for now we just SPOOF the value as being
              # nil so that it falls thru "elegantly". we might change this.

              @_current_sanitized_value = nil

            else

              # when none of the (counting) 4 above conditions are met,
              # there's nothing to do for this field. (there would PROBABLY
              # be no harm in sending NIL here but we're gonna wait until
              # we feel that we want it..)

              next
            end

            # EEW - we never FOO so we never BAR
            @_do_advance_EEW = false  # not necessary only the 1st time EEW
            _maybe_check_required_and_maybe_send  # assume value was resolved
          end

          NIL
        end

        def __resolve_sanitized_value_via_ad_hoc_normalizer_against_nothing
          _qkn = Common_::QualifiedKnownness.via_association @_current_association
          _resolve_sanitized_value_via_ad_hoc_normalizer _qkn
        end

        def __the_property_store_already_has_an_existent_value

          _x = @read_by[ _sanitized_key ]
          _qualifies_as_existent _x
        end

        def __no_more_associations_in_diminishing_pool

          if @_diminishing_pool_key_scanner.no_unparsed_exists
            @_current_association = nil  # #not-taking-any-chances
            remove_instance_variable :@_current_association
            remove_instance_variable :@_diminishing_pool_key_scanner ; true
          else
            _k = @_diminishing_pool_key_scanner.gets_one
            @_current_association = @_association_via_name_symbol[ _k ]
            FALSE
          end
        end

        def __init_diminishing_pool_traversal
          @_diminishing_pool_key_scanner = Common_::Scanner.via_array(
            remove_instance_variable( :@_diminishing_pool ).keys ) ; NIL
        end

        # -- G

        def _maybe_check_required_and_maybe_send

          x = remove_instance_variable :@_current_sanitized_value

          if _is_required
            if _qualifies_as_existent x
              _SEND_THIS_VALUE x
            else
              ( @_missing_requireds ||= {} )[ _sanitized_key ] = true
            end
          else
            _SEND_THIS_VALUE x
          end
          NIL
        end

        def _SEND_THIS_VALUE x

          if _is_glob
            __send_this_when_glob x
          else
            send @_write_current_value, x
          end

          _yes = remove_instance_variable :@_do_advance_EEW
          _yes && @argument_scanner.advance_one
          NIL
        end

        def __send_this_when_glob x

          a = send @_read_current_value
          if a
            a.concat x  # also [#008.2]
          else
            send @_write_current_value, x
          end
          NIL
        end

        def __write_current_value_entily x
          @entity._write_via_association_ x, @_current_association
          NIL
        end

        def __write_current_value_simply x
          @write_by[ _sanitized_key, x ]
          NIL
        end

        def __read_current_knownness
          _kn = @entity._read_knownness_ @_current_association  # #todo [#fi-037.X]
          _kn || self._NEVER  # #todo sanity
          _kn
        end

        def __read_current_value_simply
          @read_by[ _sanitized_key ]
        end

        def _qualifies_as_existent x
          if x  # imagine ::BasicObject
            TRUE
          elsif x.nil?
            FALSE  # hi.
          else
            self._COVER_ME__meaningful_false__
            TRUE  # meaninful false. hi.
          end
        end

        def _is_required
          @_current_association.is_required
        end

        # -- F ALTERNATIVE

        def __value_normalizer

          p = ValueNormalizer_via___.call_by do |o|

            o.default_knownness_via_association_by = -> asc do

              _wat = asc.default_value_via_entity__ @entity
              # (the above interface does not allow for failure, but
              # it's going away anyway..)
              Common_::KnownKnown[ _wat ]
            end

            o.receive_missing_by = -> kn, chan, & ev_p do
              send @_receive_missing_reasons, ev_p, kn, chan
            end

            o.listener = @listener
          end

          -> kn do
            p[ kn, @_current_association ]
          end
        end

        def __receive_missing_reasons_normally ev_p, kn, chan

          # :[#008.6]: #borrow-coverage from [br]

          _asc_a = ev_p[].reasons
          ( @_missing_required_associations ||= [] ).concat _asc_a
          kn  # don't stop cold on these - aggregate and procede.
        end

        # -- F

        def __resolve_sanitized_value_via_unsanitized_value

          @_diminishing_pool.delete _sanitized_key

          # (the below "many worlds" tree is not covered to the letter in
          #  the pseudocode, but is nonetheless test-driven)

          if _qualifies_as_existent @_current_unsanitized_value

            # whenever an existent value was passed, never use defaulting

            _normalizer_or_YIKES

          elsif _resolve_a_default_value

            # if we got here, NIL was passed and a default value was resolved

            ACHIEVED_
          else

            # when NIL is passed and defaulting is unavailable, see.

            _normalizer_or_YIKES
          end
        end

        def _normalizer_or_YIKES

          if _has_ad_hoc_normalizer
            if _is_glob
              self._HAVE_FUN__shouldnt_be_that_bad__
            else
              __resolve_sanitized_value_via_ad_hoc_normalizer_against_something
            end
          else
            __use_the_unsanitized_value_as_the_sanitized_value_YIKES
          end
        end

        def __resolve_sanitized_value_via_ad_hoc_normalizer_against_something

          # :[#008.3] #borrow-coverage from [sn]

          _x = remove_instance_variable :@_current_unsanitized_value
          _qkn = Common_::QualifiedKnownness[ _x, @_current_association ]  # NOTE RIDE
          _resolve_sanitized_value_via_ad_hoc_normalizer _qkn
        end

        def __use_the_unsanitized_value_as_the_sanitized_value_YIKES

          _x = remove_instance_variable :@_current_unsanitized_value
          @_current_sanitized_value = _x ; true
        end

        def _resolve_a_default_value
          # #here-3.A: the best
          kn_by = @_current_association.default_by
          if kn_by
            a = @arguments_to_default_proc_by[ _sanitized_key ]
            p = a.pop
            kn = kn_by[ * a, & p ]
            if kn
              @_current_sanitized_value = kn.value_x ; true
            end
          end
        end

        def _has_ad_hoc_normalizer
          @_current_association.normalize_by
        end

        def _resolve_sanitized_value_via_ad_hoc_normalizer qkn

          kn = @_current_association.normalize_by[ qkn, & @listener ]

          if kn
            if kn.is_known_known
              @_current_sanitized_value = kn.value_x
            else
              @_current_sanitized_value = NOTHING_  # hi. ([sn])
            end
            ACHIEVED_
          else
            # assume the remote normalizer emitted some compaint.
            _unable
          end
        end

        # -- E

        def __maybe_check_clobber

          k = _sanitized_key
          if @_seen[ k ]
            if _is_glob
              ACHIEVED_  # :[#008.2] #borrow-coverage from [sn]
            else
              self._COVER_ME__this_is_supposed_to_be_not_OK__
            end
          else
            @_seen[ k ] = true ; true
          end
        end

        # -- D

        def __resolve_unsanitized_value_for_this_primary

          ok = false ; unsanitized_value = nil

          @_current_unsanitized_value = nil  # #not-taking-any-chances
          remove_instance_variable :@_current_unsanitized_value

          if _is_glob

            a = @argument_scanner.scan_glob_values
            if a
              @_current_unsanitized_value = a ; true  # <-- LOOK
            else
              _unable
            end

          elsif _is_flag

            kn = @argument_scanner.scan_flag_value
            if kn
              @_current_unsanitized_value = kn.value_x
            else
              _unable
            end
          else
            @argument_scanner.map_value_by do |x|
              @_do_advance_EEW = true
              ok = true ; unsanitized_value = x ; nil
            end
            if ok
              @_current_unsanitized_value = unsanitized_value ; true
            else
              _unable
            end
          end
        end

        def _is_flag
          @_current_association.is_flag
        end

        def _is_glob
          @_current_association.is_glob
        end

        # -- C

        def __match_argument_scanner_head_against_associations

          if @argument_scanner.scan_primary_symbol

            asc = @_association_via_name_symbol[ _unsanitized_key ]
            if asc
              @_current_association = asc ; true
            else
              __when_primary_not_found
            end
          else
            _unable
          end
        end

        def __gets_association
          asc = @association_stream.gets
          if asc
            @_current_association = asc ; TRUE
          else
            remove_instance_variable :@_current_association ; FALSE
          end
        end

        def __when_primary_not_found

          _built_it_early = __build_primary_not_found_event  # for now NOTE

          @listener.call :error, :argument_error, :primary_not_found do
            _built_it_early
          end

          _unable
        end

        def __build_primary_not_found_event

          _did_you_mean = @_association_via_name_symbol.keys

          _ev = Home_::Events::Extra.build [ _unsanitized_key ], _did_you_mean

          _ev  # hi. #todo
        end

        def _sanitized_key
          @_current_association.name_symbol
        end

        def _unsanitized_key
          @argument_scanner.current_primary_symbol
        end

        def _unable
          @_ok = false ; UNABLE_
        end

        # -- B

        def __no_more_arguments
          send ( @_no_more_arguments ||= :__no_more_arguments_initially )
        end

        def __no_more_arguments_initially

          if @argument_scanner and ! @argument_scanner.no_unparsed_exists

            @_no_more_arguments = :__no_more_arguments_normally
            send @_no_more_arguments
          else
            @_no_more_arguments = :_ONCE ; true
          end
        end

        def __no_more_arguments_normally

          @_do_advance_EEW = false  # be OCD about [#ze-052.2] don't advance until valid
          @argument_scanner.no_unparsed_exists
        end

        # -- A

        def __index_associations

          diminishing_pool = {} ; h = {}

          st = remove_instance_variable :@association_stream

          begin
            asc = st.gets
            asc || break

            if asc.is_required || asc.default_by || asc.normalize_by
              diminishing_pool[ asc.name_symbol ] = true
            end

            h[ asc.name_symbol ] = asc

            redo
          end while above

          @_diminishing_pool = diminishing_pool
          @_association_via_name_symbol = h
          @_ok = true ; @_missing_requireds = nil ; @_seen = {} ; nil
        end
      end

      # ==  # :#here-1

      class << self
        public :define  # for #spot-1-3
      end  # >>

      def initialize
        @__execute_once_mutex = nil  # useful only during transition to MagneticBySimpleModel
        @listener = nil
        super
      end

      def ivar_store= ivar_store
        @store = Ivar_based_Store.new ivar_store
        ivar_store
      end

      def box_store= bx
        @store = Box_based_Store___.new bx
        bx
      end

      def use_empty_store
        @store = The_empty_store___[]
        NIL_
      end

      attr_writer(
        :listener,
      )

      attr_accessor(
        :effectively_defaultants,
        :lookup,
        :requireds,
      )

      def execute

        remove_instance_variable :@__execute_once_mutex

        _ok = check_for_missing_requireds
        _ok && ___apply_defaulting
      end

      def ___apply_defaulting  # near #spot-1-2. sometimes always, but maybe not.
        if @effectively_defaultants
          ___do_apply_defaulting
        else
          ACHIEVED_
        end
      end

      def ___do_apply_defaulting

        @effectively_defaultants.each do |k|

          atr = @lookup[ k ]

          if @store.knows atr
            was_defined = true
            x = @store.retrieve atr
          end

          if x.nil?
            p = atr.default_proc
            if p
              @store.set p[], atr
            elsif ! was_defined
              @store.set nil, atr
            end
          end
        end

        ACHIEVED_
      end

      def check_for_missing_requireds
        if @requireds
          ___do_check_for_missing_requireds
        else
          ACHIEVED_
        end
      end

      def ___do_check_for_missing_requireds

        miss_a = nil

        @requireds.each do |k|

          atr = @lookup[ k ]

          if @store.knows atr
            x = @store.retrieve atr
          end

          if x.nil?
            ( miss_a ||= [] ).push atr
          end
        end

        if miss_a
          __when_missing_requireds miss_a
        else
          ACHIEVED_
        end
      end

      def __when_missing_requireds miss_a  # :#here-2

        build_event = -> do
          Home_::Events::Missing.via miss_a, 'attribute'
        end

        if @listener
          @listener.call :error, :missing_required_attributes do
            build_event[]
          end
          UNABLE_
        else
          _ev = build_event[]
          raise _ev.to_exception
        end
      end

      attr_reader(
        :store,
      )

      # ==

      class ValueNormalizer_via___ < Common_::MagneticBySimpleModel

        attr_writer(
          :default_knownness_via_association_by,
          :listener,
          :receive_missing_by,
        )

        def execute

          -> kn, asc, & x_p do

            # 1. if value is unknown and defaulting is available, apply it.

            if ! kn.is_effectively_known && Home_::Has_default[ asc ]

              kn_ = @default_knownness_via_association_by[ asc ]
              if kn_
                # (replace the effectively unknown with what was produced
                # by the defaulting IFF the defaulting didn't fail #[#012.E])
                kn = kn_
              end
            end

            # (it may be that you don't know the value and there is no default)

            # 2. if there are ad-hoc normalizations, apply those. (was [#ba-027])

            bx = asc.ad_hoc_normalizer_box
            if bx
              kn = __add_hocs kn, bx, asc, & x_p
            end

            # 3. if this is a required property and it is unknown, act.
            #    (skip this if the field failed a normalization above.)

            if kn

              if ! kn.is_effectively_known && Home_::Is_required[ asc ]

                kn = @receive_missing_by.call kn, MISSING___ do

                  Home_::Events::Missing.for_attribute asc
                end
              end
            end

            kn
          end
        end

        MISSING___ = [ :error, :missing_required_properties ].freeze

        def __add_hocs kn, bx, model, & x_p

          # ad-hocs need to know the property too (née "trios not pairs")

          bx.each_value do | norm_norm_p |

            # at each step, value might have changed. [#053]

            _qkn = kn.to_qualified_known_around model

            kn = norm_norm_p[ _qkn, & ( x_p || @listener ) ]  # (was [#072])
            kn or break
            kn.is_qualified and self._SHAPE_ERROR_we_want_QKNs_in_and_KNs_out
          end

          kn
        end
      end

      # ==

      Get_parameter_controller_moniker = -> ent do  # legacy

        s_a = ent.class.name.split CONST_SEP_

        case 2 <=> s_a.length
        when -1  # long
          s_a = s_a[ -2 .. -1 ]
          has_two = true
        when 0
          has_two = true
        end

        if has_two
          if UNDERSCORE_ == s_a.first[ -1 ]  # assume Actors_::Foo
            s_a.shift
          else
            s_a.reverse!  # assume Noun::Verb -> 'verb noun'
          end
        end

        p = Common_::Name::Conversion_Functions::Pathify
        s_a.map do | s |
          p[ s ]
        end * SPACE_
      end

      # ==

      class Box_based_Store___ < ::BasicObject

        def initialize bx
          @_box = bx
        end

        def knows atr
          @_box.has_key atr.name_symbol
        end

        def retrieve atr
          @_box.fetch atr.name_symbol
        end
      end

      # ==

      The_empty_store___ = Lazy_.call do

        class The_Empty_Store____ < ::BasicObject
          def knows _
            false
          end
          new
        end
      end

      UNDERSCORE_ = '_'
    end
  end
end
# #history-037.5.G - "normalization against model" (file assimilated)
