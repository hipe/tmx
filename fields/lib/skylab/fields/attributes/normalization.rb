module Skylab::Fields

  class Attributes

    module Normalization  # main algorithm in [#012], "one ring" in [#037]

      # (NOTE at the moment this file/node has both the older (oldest)
      # implemention of normalization used in "attributes actor" (2nd half)
      # and the newest one for model-centric zerk microservices. they are
      # near each other to encourage re-use, but the full realization of
      # this dream is harder than it sounds..)

      module FACILITY_I
        # (this used to be its own facility, and lived in "association index"
        # #todo - this can go away completely, but we want to incubate it
        class << self
          def call_by
            Here_::Normalization::EK.call_by do |o|
              o.BE_FACILITY_I  # DOES NOTHING
              yield o
            end
          end
        end  # >>
      end

      Normalize_via_Entity_with_StaticAssociations = -> ent, & p do

        # (bridge the older-but-still-newish "attribute actor"-style
        # into the file-eponymous node, which starts #here-1)

        ascs = ent.class::ATTRIBUTES
        if ascs

          idx = ascs.index_
          sidx = idx.static_index_

          Facility_C.call_by do |o|
            o.non_required_name_symbols = sidx.non_required_name_symbols
            o.ivar_store = ent
            o.read_association_by = idx.read_association_by_
            o.required_name_symbols = sidx.required_name_symbols
            o.listener = p
          end
        else
          ACHIEVED_
        end
      end

      # ==

      class Facility_C < Common_::MagneticBySimpleModel

        # (when you try to unify this with "one ring", have fun because
        # it's called like 186 times (or places).)

        # (this facility is for attributes actors. its lineage traces back
        # to the origin of this file. it moved locations in the file. as
        # as appropriate we may dissolve techniques found here *downwards*
        # into "EK". but for now, it is kept separate because these index-
        # centric techniques are isolated in their application.)

        def initialize
          @_execute = :__execute_normally
          yield self
        end

        attr_writer(
          :non_required_name_symbols,
          :listener,
          :read_association_by,
          :required_name_symbols,
        )

        def WILL_USE_EMPTY_STORE  # [ta]
          @value_store = THE_EMPTY_VALUE_STORE___ ; nil
        end

        def box_store= bx
          @value_store = BoxBasedValueStore___.new bx ; bx
        end

        def ivar_store= entity  # #here-5
          @value_store = IvarBasedValueStore.new entity ; entity
        end

        def WILL_CHECK_FOR_MISSING_REQUIREDS_ONLY
          @_execute = :_check_for_missing_requireds ; nil
        end

        def execute
          send remove_instance_variable :@_execute
        end

        def __execute_normally
          ok = _check_for_missing_requireds
          ok && __maybe_apply_defaults
          ok
        end

        def __maybe_apply_defaults
          if @non_required_name_symbols
            __apply_defaults
          end
        end

        def __apply_defaults

          @non_required_name_symbols.each do |k|

            asc = @read_association_by[ k ]

            if @value_store.knows asc
              x = @value_store.dereference asc
            end

            x.nil? || next

            p = asc.default_proc
            if p
              x = p[]
            end
            @value_store.write_via_association x, asc
          end
          NIL
        end

        def _check_for_missing_requireds
          if @required_name_symbols
            __do_check_for_missing_requireds
          else
            ACHIEVED_
          end
        end

        def __do_check_for_missing_requireds

          miss_asc_a = nil

          @required_name_symbols.each do |k|

            asc = @read_association_by[ k ]

            if @value_store.knows asc
              x = @value_store.dereference asc
            end

            x.nil? || next

            ( miss_asc_a ||= [] ).push asc
          end

          if miss_asc_a
            __when_missing_requireds miss_asc_a
          else
            ACHIEVED_
          end
        end

        def __when_missing_requireds miss_asc_a  # :#here-2

          if @listener
            @listener.call :error, :missing_required_attributes do
              _build_event miss_asc_a
            end
            UNABLE_
          else
            _ev = _build_event miss_asc_a
            raise _ev.to_exception
          end
        end

        def _build_event miss_asc_a
          Home_::Events::Missing.with(
            :reasons, miss_asc_a,
            :noun_lemma, "attribute",
          )
        end

        # (all for hacky experiment, :[#008.7]: #borrow-coverage from [ta])

        attr_reader(
          :non_required_name_symbols,
          :read_association_by,
          :required_name_symbols,
          :value_store,
        )
      end

      # ==

      class EK < Common_::MagneticBySimpleModel

        # this is "one ring": the place where normalization algorithms
        # go to achieve immortality.

        # (this is awfully close to operator branches, but with all the
        #  defaulting and required-ness stuff going on, we go it alone.)

        # we just finished writing the massive but ostensibly "complete"
        # [#012] new normalization algorithm in detailed pseudocode.
        #
        # what you see here is an exercise of the greatest OCD ever:
        # a faithful reproduction (to the letter) of that algorithm,
        # driven by three-laws.

        # local conventions:
        #
        #   - use the `__no_more_foo` pattern to jive semantically
        #     with the ubiquitous `no_unparsed_exists` of scanners

        def initialize

          @_execute = :__execute_ideally
          @_mutex_only_one_special_instructions_for_result = nil
          @__mutex_only_one_valid_value_store = nil
          @_receive_missing_required_MIXED_associations = :__receive_missing_required_MIXED_associations_simply
          @_result = :__result_normally

          @argument_scanner = nil
          @association_is_required_by = nil
          @listener = nil
          yield self
        end

        # ---

        def BE_FACILITY_I
          @IS_FAC_I = true
        end

        # -- specify the argument source (if any)

        def argument_scanner= scn

          # ##here-6 for now we are not giving special separate exposure
          # for "interfacey" argument scanners vs plain old scanners.
          # but we might one day..
          #
          # we wanted them to have a uniform interface but that might
          # not be easy

          if scn.respond_to? :scan_glob_values
            __accept_complex_argument_scanner scn
          else
            _accept_simple_argument_scanner scn
          end
        end

        def argument_array= a
          _accept_simple_argument_scanner Scanner_[ a ]
          a
        end

        def __accept_complex_argument_scanner scn
          @_initial_value_for_do_advance = false  # complex - be OCD about [#ze-052.2] don't advance until valid
          @_resolve_unsanitized_value = :__resolve_unsanitized_value_complicatedly
          @_scan_primary_symbol = :__scan_primary_symbol_complicatedly
          @_unsanitized_key = :__unsanitized_key_complicatedly
          @argument_scanner = scn
        end

        def _accept_simple_argument_scanner scn
          @_initial_value_for_do_advance = true  # always advance scanner
          @_resolve_unsanitized_value = :__resolve_unsanitized_value_simply
          @_scan_primary_symbol = :__scan_primary_symbol_simply
          @_unsanitized_key = :__unsanitized_key_simply
          @argument_scanner = scn
        end

        # -- specify the value store ("entity") (if any)

        def entity= ent

          # REMINDER: do nothing magical or presumptive here. at #spot-1-6
          # the toolkit wires an entity up to normalization "manually" so
          # we cannot (and should not) assume to know that the valid value
          # store is an entity thru the use of this method..

          if ent.respond_to? :_receive_missing_required_associations_
            # #here-3 this should be temporary, only while [br]-era entities
            @_receive_missing_required_MIXED_associations =
              :__receive_missing_required_MIXED_associations_entily
          end

          @entity = ent
        end

        def ivar_store= object
          _receive_valid_value_store IvarBasedSimplifiedValidValueStore___.new object
          object
        end

        def write_by= p
          _receive_proc_for_proc_based_value_store :__receive_write_by_proc_, p
          p
        end

        def read_by= p
          _receive_proc_for_proc_based_value_store :__receive_read_by_proc_, p
          p
        end

        def _receive_proc_for_proc_based_value_store m, p
          @_PBSVS_in_progress ||= BuildProcBasedSimplifiedValidValueStore__.new
          vvs = @_PBSVS_in_progress.__receive_ m, p
          if vvs
            remove_instance_variable :@_PBSVS_in_progress
            _receive_valid_value_store vvs
          end
          p
        end

        def _receive_valid_value_store vvs
          remove_instance_variable :@__mutex_only_one_valid_value_store
          @_valid_value_store = vvs ; nil
        end

        # -- specify the behavior of the parse

        def will_parse_passively__
          @__do_parse_passively = true
        end

        def will_result_in_entity_on_success_
          remove_instance_variable :@_mutex_only_one_special_instructions_for_result
          @_result = :__result_in_entity ; nil
        end

        def EXECUTE_BY= p
          remove_instance_variable :@_mutex_only_one_special_instructions_for_result
          @_execute = :__execute_via_custom_proc ; @__execute_by = p
        end

        # -- specify the associations

        def association_index= asc_idx

          # if this method receives an association index (or even if it
          # doesn't) it changes the parsing algorithm to [#012.F]

          @__do_parse_passively ||= false

          @_execute = :__execute_DRIVEN_BY_ASSOCIATION_INDEX
          @_receive_entity = :_receive_entity_simply

          if asc_idx

            sidx = asc_idx.static_index_
            if sidx.non_required_name_symbols  # [#012.B]
              yes = true
            end

            asc_h = asc_idx.hash_
            _push_association_soft_reader_by do |k|
              asc_h[ k ]  # (hi.)
            end
          end

          @__has_non_requireds = yes
          @association_index = asc_idx
        end

        def member_array= sym_a  # #feature-island (intentional, experimental)
          @_do_sound_like_struct = true  # ..
          @_association_stream = :__association_stream_via_member_array
          @__member_array = sym_a
        end

        def association_stream= st
          @_do_sound_like_struct = false  # ..
          @_association_stream = :__association_stream_as_is
          @__association_stream = st
        end

        def push_association_soft_reader_by__ & p
          _push_association_soft_reader_by( & p )
        end

        def _push_association_soft_reader_by & p
          ( @_association_soft_reader ||= Here_::AssociationIndex_::StackBasedAssociationSoftReader.new ).
            push_association_soft_reader_proc__ p
        end

        # --

        attr_writer(
          :arguments_to_default_proc_by,
          :association_is_required_by,
          :listener,
        )

        # --

        def execute
          send @_execute
        end

        def __execute_DRIVEN_BY_ASSOCIATION_INDEX
          if __parse_any_arguments_FUN
            if __normalize_FUN
              send @_result
            end
          end
        end

        def __parse_any_arguments_FUN
          if @argument_scanner
            __do_parse_arguments_FUN
          else
            KEEP_PARSING_
          end
        end

        def __normalize_FUN
          if @__has_non_requireds
            _wee = @association_index.AS_INDEX_NORMALIZE_BY do |o|
              o.ivar_store = @entity
              o.listener = @listener
            end
            _wee  # hi. #todo
          else
            KEEP_PARSING_
          end
        end

        def __execute_ideally

          __init_association_stream

          if @argument_scanner  # (assimilating [#037.5.G] is when this became a branch)
            __index_associations
            ok = __traverse_arguments
            ok &&= __traverse_associations_remaining_in_pool
          else
            ok = __traverse_associations_all
          end

          ok && __if_there_were_any_missing_requireds_emit
        end

        def __traverse_arguments

          @_ok = true

          until __no_more_arguments

            __match_argument_scanner_head_against_associations || break

            __resolve_unsanitized_value_for_this_primary || break

            __maybe_check_clobber || break

            __resolve_sanitized_value_via_unsanitized_value || break

            _maybe_check_required_and_maybe_send
          end

          remove_instance_variable :@_ok
        end

        def __do_parse_arguments_FUN

          kp = KEEP_PARSING_
          softly = __flush_association_soft_reader
          scn = @argument_scanner

          until scn.no_unparsed_exists
            asc = softly[]
            if ! asc
              kp = __at_extra_FUN
              break
            end
            scn.advance_one
            kp = asc.as_association_interpret_ self, & @listener  # result is "keep parsing"
            kp || break
          end

          kp
        end

        def __execute_via_custom_proc

          # this branch is a much more constrainted, beurocratic and
          # formalized means of doing what we used to do, which was plain
          # and pass it around. (#tombstone-B in "association index")

          p = remove_instance_variable :@__execute_by
          freeze  # to send this object out into the wild, would be irresponsible not to
          _the_result = p[ self ]
          _the_result  # hi. #todo
        end

        # -- J: traversing the "extroverted" associations

        # when there are arguments to parse, the most intuitive, practical
        # (if not only) option is to acquire (somehow) a dictionary (hash)
        # of valid association names that can be used to parse-off each
        # valid "head" of the arguments (as an argument scanner).

        # because our lingua-franca representation of associations is as
        # a stream, when we need such a hash we traverse (and exhaust) the
        # stream, converting it into such a hash.

        # when doing so, we must also make note of those associations that
        # are "extroverted", and put them in a [#ba-061] "diminishing pool".
        # thru this means, any "extroverted" associations that weren't
        # involved in the argument parsing phase still get the attention
        # they need to complete the normalization.

        # however, in cases where there ws no argument stream to parse, any
        # (#here-11) "extroverted" associations still need this special
        # attention. since in such cases we never made an indexing pass, we
        # achive a similar effect through a stream reduction..

        def __traverse_associations_remaining_in_pool

          __init_extroverted_associations_via_flush_diminishing_pool

          _traverse_extroverted_and_with_each_sanitized_value do

            # reset this flag to whatever is default (T/F) before each send

            @_do_advance_scanner_after_write = @_initial_value_for_do_advance

            _maybe_check_required_and_maybe_send
          end
        end

        def __traverse_associations_all

          __init_extroverted_associations_when_you_have_not_already_indexed

          send @_traverse_associations_all
        end

        def __traverse_associations_all_LEGACY_ENTITY_ALGORITHM

          # we used to think this was the bee's knees because of its use of
          # knownnesses; but now it's deprecated and on its way out because
          # of its flagrant disregard for [#012.5.3]: it normalizes values
          # already in the "valid value store".  (really, it uses the
          # "valid value store" not as such, but as just an unsanitized
          # parameter store.) since this change in convention hasn't
          # percolated out to all the clients, we've got to keep it around
          # for now..

          kp = true ; new_kn = nil ; native_asc = nil

          write_value = -> do
            @entity._write_via_association_ new_kn.value_x, native_asc
          end

          normalize_value = __value_normalizer_for_LEGACY_ENTITY_ALGORITHM

          st = remove_instance_variable :@__native_association_stream
          begin
            native_asc = st.gets
            native_asc || break

            existing_kn = @entity._read_knownness_ native_asc
            existing_kn || self._NEVER

            new_kn = normalize_value[ existing_kn, native_asc ]
            if ! new_kn
              kp = new_kn ; break
            end

            if existing_kn.is_known_known
              if new_kn.is_known_known
                if existing_kn.object_id == new_kn.object_id
                  NOTHING_  # #covered
                else
                  write_value[]
                end
              else
                self._COVER_ME__became_unknown__
              end
            elsif new_kn.is_known_known
              write_value[]
            end
            redo
          end while above
          kp
        end

        def _traverse_associations_all_modernly

          @_do_advance_scanner_after_write = false  # no scanner at all

          _traverse_extroverted_and_with_each_sanitized_value do

            _maybe_check_required_and_maybe_send
          end
        end

        def __init_extroverted_associations_via_flush_diminishing_pool

          _keys = remove_instance_variable( :@_diminishing_pool ).keys

          # although we have the option of checking for an empty array above
          # (and it does occur), because it still "just works" as-is when
          # the array is empty (and has relatively low overhead), the law of
          # parsimony suggests that we don't weigh ourselves down with
          # special code for this case.

          # in an accidental or (don't) real world where a false-ish key is
          # a valid association key (it's called `name_symbol`, so just don't)
          # we wouldn't want that false-ish-ness to break our stream early so:

          key_scn = Scanner_[ _keys ]

          @_remaining_extroverted_stream = Common_.stream do
            if ! key_scn.no_unparsed_exists
              _k = key_scn.gets_one
              @_normal_association_via_name_symbol.fetch _k
            end
          end
          NIL
        end

        def __init_extroverted_associations_when_you_have_not_already_indexed

          # this method could be only four lines long (reduce the stream to
          # be only those that are extroverted); BUT we are too stubborn to
          # expose specialized setters for the different kind of associations
          # (legacy [br]-era vs latest) (#here-3 and another ##here-6)
          # so instead we've gotta peek at the first association, see what
          # kind it is, and assume that the way it looks represents the
          # association implementation of each remaining item them. we are
          # tempted to change this (make the interface cruchier to the
          # benefit of cleaner implementation) so we are trying to isolate
          # the ramifications of this choice to this method.

          asc_st = remove_instance_variable :@association_stream
          first_asc = asc_st.gets
          if first_asc

            p = -> { p = asc_st ; first_asc }
            this_asc_st = Common_.stream { p[] }

              @_traverse_associations_all = :__traverse_associations_all_LEGACY_ENTITY_ALGORITHM
              @__native_association_stream = this_asc_st
            if first_asc.respond_to? :parameter_arity
            else
              @_traverse_associations_all = :_traverse_associations_all_modernly
              @_remaining_extroverted_stream = this_asc_st.reduce_by do |asc|
                _association_is_extroverted asc  # hi.
              end
            end
          else
            @_traverse_associations_all = :_traverse_associations_all_modernly
            @_remaining_extroverted_stream = Common_::THE_EMPTY_STREAM
          end
          NIL
        end

        def _association_is_extroverted asc  # :#here-11
          asc.is_required || asc.default_by || asc.normalize_by
        end

        # here we restate the pertinent points of our central algorithm
        # so that they shadow the structure of the below method, literate-
        # programming-like:

        # if the value is already present in the "valid value store", then
        # we must assume it is valid and there is nothing more to do for
        # this association. ([#012.E.3])

        # if you succeeded in resolving a default value (which requires
        # that a defaulting proc is present and that a call to it didn't
        # fail), then per [#012.E.2] we must assume this value is already
        # "normalized" and as such we must cicumvent any ad-hoc
        # normalization. so if we resolved a default (which could possibly
        # be `nil`), fall through to the send.

        # if you got this far,
        #
        #   - there is effectively no corresponding value in the valid
        #     value store. (either it's set to `nil` or it's not set
        #     at all.)
        #
        #   - a default value was not resolved for one of two reasons.
        #
        # as long as we're treating explicit `nil` indifferently from
        # "not set" (which we should; yuck if we don't), then we're going to
        # set it up to look as if the value was explicitly set to `nil`, and
        # use the same code that we use in those cases (per the law of
        # parsimony).

        # if no default, no normalizer, and it's not required; then there's
        # nothing to do for this field. (there would PROBABLY be no harm in
        # sending NIL here but we're gonna wait until we feel that we want
        # it..) #wish [#012.10] "nilify" option

        def _traverse_extroverted_and_with_each_sanitized_value

          @_ok = true

          until __no_more_remaining_extroverted_associations

            if __the_valid_value_store_already_has_an_existent_value
              next
            end

            if _resolve_sanitized_value_via_default

              NOTHING_  # fall through to send

            elsif @_current_normal_association.normalize_by

              if ! __resolve_sanitized_value_via_ad_hoc_normalizer_against_NOTHING

                break  # normalization failed. withdraw from everything
              end

            elsif @_current_normal_association.is_required

              @_current_sanitized_value = nil
            else

              next  # because nothing to send
            end

            yield
          end

          # (if missing requireds were encountered (only), it's still OK)

          remove_instance_variable :@_ok
        end

        def __resolve_sanitized_value_via_ad_hoc_normalizer_against_NOTHING
          _qkn = Common_::QualifiedKnownness.via_association @_current_normal_association
          _resolve_sanitized_value_via_ad_hoc_normalizer _qkn
        end

        def __the_valid_value_store_already_has_an_existent_value

          _x = _simplified_read_of_current_valid_value
          _qualifies_as_existent _x
        end

        def __no_more_remaining_extroverted_associations
          asc = @_remaining_extroverted_stream.gets
          if asc
            @_current_normal_association = asc ; false
          else
            @_current_normal_association = nil ;  # stream may have started empty
            remove_instance_variable :@_current_normal_association
            remove_instance_variable :@_remaining_extroverted_stream ; true
          end
        end

        # -- I: sending a sanitized value to the valid value store

        def _maybe_check_required_and_maybe_send

          x = remove_instance_variable :@_current_sanitized_value

          if @_current_normal_association.is_required
            if _qualifies_as_existent x
              _SEND_THIS_VALUE x
            else
              __add_current_association_as_a_missing_required_asociation
            end
          else
            _SEND_THIS_VALUE x
          end
          NIL
        end

        def _SEND_THIS_VALUE x

          if @_current_normal_association.is_glob
            __send_this_when_glob x
          else
            _write_value x
          end

          if @_do_advance_scanner_after_write
            @argument_scanner.advance_one
          end
          NIL
        end

        def __send_this_when_glob x

          a = _simplified_read_of_current_valid_value
          if a
            a.concat x  # also [#008.2]
          else
            _write_value x
          end
          NIL
        end

        def _write_value x
          @_valid_value_store._simplified_write_ x, _association_key
          NIL
        end

        def _qualifies_as_existent x
          if x  # imagine ::BasicObject
            TRUE
          elsif x.nil?
            FALSE  # hi.
          else
            self._COVER_ME__meaningful_false__
            TRUE  # meaningful false. hi.
          end
        end

        def _simplified_read_of_current_valid_value
          @_valid_value_store._simplified_read_ _association_key
        end

        # -- H alternative: for legacy

        def __value_normalizer_for_LEGACY_ENTITY_ALGORITHM

          LEGACY_ENTITY_ALGORIHTM_ValueNormalizer_via___.call_by do |o|

            o.default_of_association_by = -> native_asc do

              _wat = native_asc.default_value_via_entity__ @entity
              # (the above interface does not allow for failure, but
              # it's going away anyway..)
              Common_::KnownKnown[ _wat ]
            end

            o.receive_missing_native_association_by = -> kn, native_asc do

              # #coverpoint1.8

              _add_missing_required_MIXED_association native_asc

              kn  # don't stop cold on these - aggregate and procede
            end

            o.listener = @listener
          end
        end

        # -- H: normalizing (sanitizing) the particular value

        def __resolve_sanitized_value_via_unsanitized_value

          @_diminishing_pool.delete _association_key

          # (the below "many worlds" tree is not covered to the letter in
          #  the pseudocode, but is nonetheless test-driven)

          if _qualifies_as_existent @_current_unsanitized_value

            # whenever an existent value was passed, never use defaulting

            _resolve_sanitized_value_via_any_normalizer

          elsif _resolve_sanitized_value_via_default

            # if we got here, NIL was passed and a default value was resolved

            ACHIEVED_
          else

            # when NIL is passed and defaulting is unavailable, see.

            _resolve_sanitized_value_via_any_normalizer
          end
        end

        def _resolve_sanitized_value_via_any_normalizer

          if @_current_normal_association.normalize_by
            if @_current_normal_association.is_glob
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
          _qkn = Common_::QualifiedKnownness[ _x, @_current_normal_association ]  # NOTE RIDE
          _resolve_sanitized_value_via_ad_hoc_normalizer _qkn
        end

        def __use_the_unsanitized_value_as_the_sanitized_value_YIKES

          _x = remove_instance_variable :@_current_unsanitized_value
          @_current_sanitized_value = _x ; true
        end

        def _resolve_sanitized_value_via_default

          # exactly as documented, allow that defaulting can fail

          kn_by = @_current_normal_association.default_by
          if kn_by
            a = @arguments_to_default_proc_by[ _association_key ]
            p = a.pop
            kn = kn_by[ * a, & p ]
            if kn
              @_current_sanitized_value = kn.value_x ; true
            end
          end
        end

        def _resolve_sanitized_value_via_ad_hoc_normalizer qkn

          kn = @_current_normal_association.normalize_by[ qkn, & @listener ]

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

        # -- G: missing requireds: memoing and expressssing them

        def __add_current_association_as_a_missing_required_asociation

          k = _association_key

          seen = ( @_MISSING_REQUIRED_ASSOCIATIONS_SEEN_HASH_SANITY_CHECK ||= {} )
          seen[k] && self._SANITY
          seen[k] = true

          _add_missing_required_MIXED_association k

          NIL
        end

        def _add_missing_required_MIXED_association sym_or_object
          ( @_missing_required_MIXED_associations ||= [] ).push sym_or_object
        end

        def __if_there_were_any_missing_requireds_emit

          # we want to merge these two missing required techinques but if you
          # try you will see how on the one hand X but on the other Y

          # (we want to merge this one into the other one but if you try
          # you will see how we on the one hand need to represent association
          # structures and on the other hand need to de-dup them *sometimes*..)

          asc_X_a = remove_instance_variable :@_missing_required_MIXED_associations
          if asc_X_a
            send @_receive_missing_required_MIXED_associations, asc_X_a
          else
            ACHIEVED_
          end
        end

        def __receive_missing_required_MIXED_associations_simply miss_sym_a  # (#here-2 will assimilate to here)

          same_build = -> do
            __build_missing_required_event miss_sym_a
          end

          if @listener
            @listener.call :error, :missing_required_attributes do
              same_build[]
            end
            UNABLE_
          else
            _ev = same_build[]
            _e = _ev.to_exception
            raise _e
          end
        end

        def __receive_missing_required_MIXED_associations_entily asc_X_a
          # #coverpoint1.8 and #here-3 this should be temporary
          @entity._receive_missing_required_associations_ asc_X_a
        end

        def __build_missing_required_event miss_sym_a

          these = _maybe_special_noun_lemma
          these ||= [ :noun_lemma, :parameter ]  # #coverpoint1.2 ("parameters")

          _reasons = Stream_[ miss_sym_a ]

          _ev = Home_::Events::Missing.with(
            :reasons, _reasons,
            * these,
            :USE_THIS_EXPRESSION_AGENT_METHOD_TO_DESCRIBE_THE_PARAMETER, :ick_prim,
          )
          _ev  # hi. #todo
        end

        # -- F: checking for problem

        def __maybe_check_clobber

          if @_seen[ _association_key ]
            if @_current_normal_association.is_glob
              ACHIEVED_  # :[#008.2] #borrow-coverage from [sn]
            else
              self._COVER_ME__this_is_supposed_to_be_not_OK__
            end
          else
            @_seen[ _association_key ] = true ; true
          end
        end

        # -- E: resolving an unsanitized value

        def __resolve_unsanitized_value_for_this_primary
          send @_resolve_unsanitized_value
        end

        def __resolve_unsanitized_value_complicatedly

          if @_current_normal_association.is_glob
            a = @argument_scanner.scan_glob_values
            if a
              @_current_unsanitized_value = a ; true
            else
              _cannot_resolve_unsanitized
            end
          elsif _is_flag
            kn = @argument_scanner.scan_flag_value
            if kn
              @_current_unsanitized_value = kn.value_x ; true
            else
              _cannot_resolve_unsanitized
            end
          else
            unsanitized_value = nil
            ok = @argument_scanner.map_value_by do |x|
              unsanitized_value = x ; true
            end
            if ok
              @_do_advance_scanner_after_write = true
              @_current_unsanitized_value = unsanitized_value ; true
            else
              _cannot_resolve_unsanitized
            end
          end
        end

        def _is_flag
          @_current_normal_association.is_flag
        end

        def __resolve_unsanitized_value_simply

          # if the scanner ends "early" then the below just fails hard. there
          # is no special emission for this if you're using a simple scanner.

          # in "retribution" for #here-4, for the simple scanner we advance
          # past the "primary name" now.

          @argument_scanner.advance_one
          @_current_unsanitized_value = @argument_scanner.head_as_is
          ACHIEVED_
        end

        def _cannot_resolve_unsanitized
          # whether we are at the first field or not,
          @_current_unsanitized_value = nil  # #not-taking-any-chances
          remove_instance_variable :@_current_unsanitized_value
          _unable
        end

        # -- D: matching the argument scanner head against an association

        def __match_argument_scanner_head_against_associations

          if __scan_primary_symbol
            asc = @_normal_association_via_name_symbol[ _unsanitized_key ]
            if asc
              @_current_normal_association = asc
            else
              __when_primary_not_found
            end
          else
            _unable
          end
        end

        def __scan_primary_symbol
          send @_scan_primary_symbol
        end

        def __scan_primary_symbol_complicatedly
          @argument_scanner.scan_primary_symbol
        end

        def __scan_primary_symbol_simply
          # for now, nothing magical here. #here-4 is where something happens
          TRUE
        end

        def __no_more_associations
          send @_no_more_associations
        end

        def __no_more_associations_normally
          asc = @association_stream.gets
          if asc
            @_current_normal_association = asc ; false
          else
            remove_instance_variable :@_current_normal_association
            remove_instance_variable :@association_stream
            TRUE
          end
        end

        def __when_primary_not_found

          ev_early_to_be_safe = __build_primary_not_found_event  # for now NOTE

          # like #here-2, some of these are and some of these aren't like this

          if @listener

            @listener.call :error, :argument_error, :primary_not_found do
              ev_early_to_be_safe
            end

            _unable
          else
            _e = ev_early_to_be_safe.to_exception
            raise _e
          end
        end

        def  __at_extra_FUN  # #coverpoint1.5

          if @__do_parse_passively

            # in a passive parse, when you encounter an unrecognizable
            # scanner head you merely stop parsing, you do not fail.

            KEEP_PARSING_
          else
            self._COVER_ME__hmmmmm___
            _ev = Home_::Events::Extra.with :unrecognized_token, @argument_scanner.head_as_is
            raise _ev.to_exception
          end
        end

        def __build_primary_not_found_event

          _these = _maybe_special_noun_lemma

          _did_you_mean = @_normal_association_via_name_symbol.keys

          _ev = Home_::Events::Extra.with(
            :unrecognized_token, _unsanitized_key,
            :did_you_mean_tokens, _did_you_mean,
            * _these,
          )
          _ev  # hi. #todo
        end

        def _maybe_special_noun_lemma

          # { :attribute | :member | :parameter | :primary | :property | :field }

          if @_do_sound_like_struct
            [ :noun_lemma, "member" ]
          end
        end

        def _association_key
          @_current_normal_association.name_symbol
        end

        def _unsanitized_key
          send @_unsanitized_key
        end

        def __unsanitized_key_complicatedly
          @argument_scanner.current_primary_symbol
        end

        def __unsanitized_key_simply
          @argument_scanner.head_as_is
        end

        def _unable
          @_ok = false ; UNABLE_
        end

        # -- C: traversing arguments

        def __no_more_arguments
          send ( @_no_more_arguments ||= :__no_more_arguments_initially )
        end

        def __no_more_arguments_initially

          if @argument_scanner
            send( @_no_more_arguments = :__no_more_arguments_normally )
          else
            @_no_more_arguments = :_CLOSED ; true
          end
        end

        def __no_more_arguments_normally
          if @argument_scanner.no_unparsed_exists
            remove_instance_variable :@argument_scanner ; true
          else
            @_do_advance_scanner_after_write = @_initial_value_for_do_advance ; false
          end
        end

        # -- B: index associations

        def __index_associations

          h = {} ; pool = {}
          st = remove_instance_variable :@association_stream

          begin
            asc = st.gets
            asc || break
            if _association_is_extroverted asc
              pool[ asc.name_symbol ] = true
            end
            h[ asc.name_symbol ] = asc
            redo
          end while above

          @_normal_association_via_name_symbol = h
          @_diminishing_pool = pool
          @_seen = {}

          NIL
        end

        def __flush_association_soft_reader
          _asr = remove_instance_variable :@_association_soft_reader
          _asr.flush_to_soft_reader_via_argument_scanner__ @argument_scanner
        end

        def __init_association_stream

          @_missing_required_MIXED_associations = nil   # snuck in here
          @association_stream = send @_association_stream
          NIL
        end

        def __association_stream_via_member_array

          is_req = remove_instance_variable :@association_is_required_by

          # (when the above is a function that produces true, #here-7)

          is_req ||= MONADIC_EMPTINESS_  # by default, "members" are not required

          Stream_.call remove_instance_variable :@__member_array do |sym|

            NormalAssociation___.new is_req[ sym ], sym
          end
        end

        NormalAssociation___ = ::Struct.new :is_required, :name_symbol do

          alias_method :intern, :name_symbol

          def default_by
            NOTHING_
          end

          def is_glob
            FALSE
          end

          def normalize_by
            NOTHING_
          end
        end

        def __association_stream_as_is
          _ = remove_instance_variable :@association_is_required_by
          _ and raise Home_::ArgumentError  # it's only for the members style
          remove_instance_variable :@__association_stream
        end

        def _yes
          TRUE
        end

        # -- A: final result

        def __result_in_entity
          # the "proper" result for a parsing performer is T/F ("keep parsing")
          # but it's convenient for some clients to have the result be this:
          remove_instance_variable :@entity
        end

        def __result_normally
          KEEP_PARSING_
        end

        attr_reader(
          :argument_scanner,  # in "defined attribute"
          :association_index,  # #coverpoint1.6
          :entity,
        )
      end

      # ==

      class LEGACY_ENTITY_ALGORIHTM_ValueNormalizer_via___ < Common_::MagneticBySimpleModel

        # we used to think this was bee's knees because of the construction
        # of a single proc that is used to traverse over every association,
        # but now this is at odds with [#012.5.2] the fact that we must not
        # run thru ad-hoc normalizers any values derived from defaulting.
        # also this has the oldschool [be]-era "native" associations with
        # the RISC methods used to reflect them. this would all change for
        # the modern age but we've got to see how this percolates out to
        # the many clients that use this, in its own work.

        attr_writer(
          :default_of_association_by,
          :listener,
          :receive_missing_native_association_by,
        )

        def execute

          -> kn, asc, & x_p do

            # 1. if value is unknown and defaulting is available, apply it.

            if ! kn.is_effectively_known && Home_::Has_default[ asc ]

              kn_ = @default_of_association_by[ asc ]
              if kn_
                # (replace the effectively unknown with what was produced
                # by the defaulting IFF the defaulting didn't fail #[#012.E])
                kn = kn_
                did = true
              end
            end

            # (it may be that you don't know the value and there is no default)

            # 2. if there are ad-hoc normalizations, apply those. (was [#ba-027])

            bx = asc.ad_hoc_normalizer_box
            if bx
              if did
                # :[#008.6]: #borrow-coverage from [br], [cu].
                # cases like these need to GO AWAY #here-3 because they are
                # in violation of [#012.5.2]
                NOTHING_  # hi.
              end
              kn = __add_hocs kn, bx, asc, & x_p
            end

            # 3. if this is a required property and it is unknown, act.
            #    (skip this if the field failed a normalization above.)

            if kn

              if ! kn.is_effectively_known && Home_::Is_required[ asc ]

                kn = @receive_missing_native_association_by[ kn, asc ]
              end
            end

            kn
          end
        end

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

      class IvarBasedSimplifiedValidValueStore___  # ideal #here-5

        def initialize object
          @_object = object
        end

        def _simplified_write_ x, k  # necessary IFF :#here-7
          @_object.instance_variable_set :"@#{ k }", x ; nil
        end

        def _simplified_read_ k
          ivar = :"@#{ k }"
          if @_object.instance_variable_defined? ivar
            @_object.instance_variable_get ivar
          end
        end
      end

      # ==

      class BuildProcBasedSimplifiedValidValueStore__

        def initialize
          @_pool = {
            __receive_read_by_proc_: :"@__read_by",
            __receive_write_by_proc_: :"@__write_by",
          }
        end

        def __receive_ m, p
          instance_variable_set @_pool.delete( m ), p
          if @_pool.length.zero?
            remove_instance_variable :@_pool
            freeze
          end
        end

        def _simplified_write_ x, k
          @__write_by[ k, x ]
          NIL
        end

        def _simplified_read_ k
          @__read_by[ k ]
        end
      end

      # ==

      class BoxBasedValueStore___ < ::BasicObject

        def initialize bx
          @_box = bx
        end

        def knows asc
          @_box.has_key asc.name_symbol
        end

        def dereference asc
          @_box.fetch asc.name_symbol
        end
      end

      # ==

      module THE_EMPTY_VALUE_STORE___ ; class << self
          def knows _
            false
          end
      end ; end

      # ==

      MONADIC_TRUTH_ = -> _ { true }

      UNDERSCORE_ = '_'

      # ==
    end
  end
end
# #history-037.5.I - experimental assimilation of the facility from "association index"
# #history-037.5.G - "normalization against model" (file assimilated)
