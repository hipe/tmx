module Skylab::Fields

  class Normalization < Common_::MagneticBySimpleModel

    # -

      # this is "one ring": the place where normalization algorithms
      # go to achieve immortality. main algorithm (etching) in [#012]

      # this feels close to an "operator branch", but for now, not yet

      # we are almost finished with [#037] the effort of "one ring"
      # unification, but this file file/node still has:
      #
      #   - the "one ring" preferred normalization facility
      #   - a clump for injection of the oldschoool [br]-era normalization #here1

      # -

        def initialize

          @__do_parse_passively = false
          @_execute = :__execute_algorithmically
          @__mutex_only_one_argument_scanner = nil
          @__mutex_only_one_association_source = nil
          @__mutex_only_one_special_execute = nil
          @__mutex_only_one_special_result = nil
          @__mutex_only_one_valid_value_store = nil
          @_my_arg_scanner = nil
          @_result = :__result_normally

          @association_source = nil
          @listener = nil
          yield self
        end

        # -- specify the argument source (if any)

        def argument_scanner= scn

          # ##here6 for now we are not giving special separate exposure
          # for "interfacey" argument scanners vs plain old scanners.
          # but we might one day..
          #
          # we wanted them to have a uniform interface but that might
          # not be easy

          if scn.respond_to? :scan_glob_values
            _receive_argument_scanner ComplexArgScanner___.new scn
          else
            _receive_simple_argument_scanner scn
          end
          scn
        end

        def argument_array= a
          _receive_simple_argument_scanner Scanner_[ a ]
          a
        end

        def _receive_simple_argument_scanner scn
          _receive_argument_scanner SimpleArgScanner___.new scn
        end

        def _receive_argument_scanner scn_ada
          remove_instance_variable :@__mutex_only_one_argument_scanner
          @_my_arg_scanner = scn_ada ; nil
        end

        def argument_scanner  # in "defined attribute"
          @_my_arg_scanner.native_argument_scanner
        end

        # -- specify the value store ("entity") (if any)

        def WILL_USE_EMPTY_STORE  # [ta]
          _receive_valid_value_store THE_EMPTY_SIMPLIFIED_VALID_VALUE_STORE___
        end

        def entity_nouveau= ent  # NOTE unlike many of the others, call-time sensitive!
          Home_::Toolkit::Receive_entity_nouveau[ self, ent ]
          ent
        end

        def entity_as_ivar_store= ent
          self.ivar_store = ent
          @entity = ent  # (until needed elsewhere, this is the one way. allows #here4
        end

        def box_store= bx
          _receive_valid_value_store(
            Home_::AssociationIndex_::BoxBasedSimplifiedValidValueStore.new bx )
          bx
        end

        def ivar_store= object
          _receive_valid_value_store IvarBasedSimplifiedValidValueStore.new object
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

        # -- specify the behavior of the parse

        def WILL_CHECK_FOR_MISSING_REQUIREDS_ONLY
          _execute_this_way :__execute_by_checking_for_missing_requireds_only
        end

        def will_parse_passively__
          @__do_parse_passively = true
        end

        def will_result_in_entity_on_success_
          _result_this_way :__result_in_entity
        end

        def WILL_RESULT_IN_SELF_ON_SUCCESS
          _result_this_way :__result_in_self
        end

        def execute_by__= p
          _result_this_way :_NEVER_CALLED
          _execute_this_way :__execute_via_custom_proc
          @__execute_by = p
        end

        def _execute_this_way m
          remove_instance_variable :@__mutex_only_one_special_execute
          @_execute = m ; nil
        end

        def _result_this_way m
          remove_instance_variable :@__mutex_only_one_special_result
          @_result = m ; nil
        end

        # -- specify the associations

        def association_index= asc_idx
          _touch_index_based.receive_association_index__ asc_idx ; asc_idx
        end

        def association_index  # #coverpoint1.6
          @association_source.association_index_
        end

        def push_association_soft_reader_by__ & p
          _touch_index_based.as_source_push_association_soft_reader_by_( & p ) ; nil
        end

        def is_required_by= p
          _touch_index_based.is_required_by= p
        end

        def _touch_index_based
          _touch_mutable_association_source do
            Home_::AssociationIndex_::BuildIndexBasedAssociationSource
          end
        end

        def member_array= sym_a  # #feature-island (intentional, experimental)
          _touch_member_based.member_array = sym_a
        end

        def association_is_required_by= p
          _touch_member_based.association_is_required_by = p
        end

        def _touch_member_based
          _touch_mutable_association_source { BuildMemberBasedAssociationSource___ }
        end

        def association_stream_oldschool= native_asc_st
          receive_association_source_ OLDSCHOOL_WHATAMI_AssociationSource___.new native_asc_st
        end

        def association_stream_newschool= normal_asc_st
          receive_association_source_ NormalAssociationStreamBasedAssociationSource___.new normal_asc_st
        end

        def _touch_mutable_association_source
          if ! @association_source
            receive_association_source_ yield.new
          end
          @association_source
        end

        def receive_association_source_ src
          remove_instance_variable :@__mutex_only_one_association_source
          @association_source = src ; nil
        end

        # --

        attr_writer(
          :arguments_to_default_proc_by,
          :listener,
        )

        # -- G: execution

        def execute
          send @_execute
        end

        def __execute_by_checking_for_missing_requireds_only
          _prepare_to_execute
          ok = @association_source.traverse_associations_checking_for_missing_requireds_only__ self
          ok &&= _react_to_any_missing_requireds
          ok and send @_result
        end

        def __execute_algorithmically

          _prepare_to_execute

          if @_my_arg_scanner  # (assimilating [#037.5.G] is when this became a branch)

            ok = __traverse_arguments
            ok &&= __traverse_associations_remaining_in_extroverted_diminishing_pool
          else
            ok = __traverse_associations_all
          end

          ok &&= _react_to_any_missing_requireds
          ok and send @_result
        end

        def _prepare_to_execute
          @_missing_required_MIXED_associations = nil
        end

        def _receive_valid_value_store vvs
          remove_instance_variable :@__mutex_only_one_valid_value_store
          @__valid_value_store = :__valid_value_store
          @__valid_value_store_object = vvs ; nil
        end

        def __traverse_arguments

          kp = KEEP_PARSING_

          o = ArgumentTraversalInjection___.new  # a simple struct
          @association_source.flush_injection_for_argument_traversal o, self

          parse = o.argument_value_parser
          @__did_you_mean_by = o.did_you_mean_by
          @__extroverted_diminishing_pool = o.extroverted_diminishing_pool
          @_mixed_association_soft_reader = o.association_soft_reader

          until __no_more_arguments

            if ! @_my_arg_scanner._scan_primary_symbol_
              kp = _unable ; break
            end

            asc = @_mixed_association_soft_reader[ _unsanitized_key ]
            if ! asc
              if @__do_parse_passively  # :#coverpoint1.5:
                # in a passive parse, when you encounter an unrecognizable
                # scanner head you merely stop parsing, you do not fail.
                break
              else
                kp = __when_primary_not_found ; break
              end
            end

            kp = parse[ asc ]
            if kp
              @_my_arg_scanner._when_primary_completed_
              # (we used to delete from the diminishing pool here but
              # now we do it #here12 instead because method-based nerks)
            else
              break  # :[#008.12] #borrow-coverage from [sn]
            end
          end

          kp
        end

        def __no_more_arguments
          if @_my_arg_scanner.__no_more_arguments_
            remove_instance_variable :@_my_arg_scanner ; true
          else
            FALSE
          end
        end

        def __execute_via_custom_proc

          # this branch is a much more constrained, beurocratic and
          # formalized means of doing what we used to do, which was plain
          # and pass it around. (#tombstone-B in "association index")

          p = remove_instance_variable :@__execute_by
          freeze  # to send this object out into the wild, would be irresponsible not to
          _the_result = p[ self ]
          _the_result  # hi. #todo
        end

        # -- F: traversing the "extroverted" associations

        # when there are arguments to parse, the most intuitive, practical
        # (if not only) option is to acquire (somehow) a dictionary (hash)
        # of valid association names that can be used to parse-off each
        # valid "head" of the arguments (as an argument scanner).

        # because our lingua-franca representation of associations is as
        # a stream (but see [#004.E]), when we need such a hash we traverse
        # (and exhaust) the stream, converting it into such a hash.

        # when doing so, we must also make note of those associations that
        # are "extroverted", and put them in a [#ba-061] "diminishing pool".
        # thru this means, any "extroverted" associations that weren't
        # involved in the argument parsing phase still get the attention
        # they need to complete the normalization.

        # however, in cases where there ws no argument stream to parse, any
        # (#here11) "extroverted" associations still need this special
        # attention. since in such cases we never made an indexing pass, we
        # achive a similar effect through a stream reduction..

        def __traverse_associations_remaining_in_extroverted_diminishing_pool

          dp = remove_instance_variable :@__extroverted_diminishing_pool
          if dp.length.zero?
            ACHIEVED_
          else
            __do_traverse_associations_remaining_in_extroverted dp.keys
          end
        end

        def __do_traverse_associations_remaining_in_extroverted keys

          o = RemainingExtrovertedTraversalInjection___.new  # simple struct

          @association_source.flush_injection_for_remaining_extroverted o, self
            # (the above method is only ever called here. nonetheless, public-API.)

          _asc_st = __association_stream_via keys
          _traverse_extroverted _asc_st, o.extroverted_association_normalizer
        end

        def __association_stream_via asc_keys

          dereference = remove_instance_variable :@_mixed_association_soft_reader
          key_scn = Scanner_[ asc_keys ]
          Common_.stream do
            if ! key_scn.no_unparsed_exists
              _k = key_scn.gets_one
              _asc = dereference[ _k ]
              _asc || self._SANITY  # this list came *from* g
            end
          end
        end

        def __traverse_associations_all

          o = FullExtrovertedTraversalInjection___.new  # a simple struct

          @association_source.flush_injection_for_full_extroverted_traversal o, self

          _ok = _traverse_extroverted(
            o.extroverted_association_stream,
            o.extroverted_association_normalizer,
          )
          _ok  # hi. #todo
        end

        def _traverse_extroverted asc_st, normalize_value

          ok = true
          begin
            mixed_asc = asc_st.gets
            mixed_asc || break
            ok = normalize_value[ mixed_asc ]
            ok || break
            redo
          end while above
          ok
        end

        # (:#here9:)

        # here we restate the pertinent points of our central algorithm
        # so that they shadow the structure of our code (somewhere),
        # literate-programming-like:

        # if the value is already present in the "valid value store", then
        # we must assume it is valid and there is nothing more to do for
        # this association. ([#012.5.3])

        # if you succeeded in resolving a default value (which requires
        # that a defaulting proc is present and that a call to it didn't
        # fail), then per [#012.E.3] we must assume this value is already
        # "normalized" and as such we must cicumvent any ad-hoc
        # normalization. so if we resolved a default (which could possibly
        # be `nil`), write this value.

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
        # it..) #wish [#012.J.4] "nilify" option

        # -- E: missing requireds (both memoing and expressing)

        def add_missing_required_MIXED_association_ sym_or_object
          ( @_missing_required_MIXED_associations ||= [] ).push sym_or_object
        end

        def _react_to_any_missing_requireds

          asc_X_a = remove_instance_variable :@_missing_required_MIXED_associations
          if asc_X_a
            __when_missing_requireds asc_X_a
          else
            KEEP_PARSING_
          end
        end

        def __when_missing_requireds asc_X_a

          if instance_variable_defined? :@entity and
              @entity.respond_to? :_receive_missing_required_associations_

            # #coverpoint1.8 and #here3 this should be temporary, or not
            @entity._receive_missing_required_associations_ asc_X_a
          else
            __express_missing_requireds asc_X_a
          end
        end

        def __express_missing_requireds miss_sym_a  # (#here2 will assimilate to here)

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

        def __build_missing_required_event miss_sym_a

          these = _maybe_special_noun_lemma
          these ||= [ :noun_lemma, :parameter ]  # #coverpoint1.2 ("parameters")

          _ev = Home_::Events::Missing.with(
            :reasons, miss_sym_a,
            * these,
            :USE_THIS_EXPRESSION_AGENT_METHOD_TO_DESCRIBE_THE_PARAMETER, :ick_prim,
          )
          _ev  # hi. #todo
        end
      # -

      # ==

      # ~

      class OLDSCHOOL_WHATAMI_AssociationSource___

        # oldschool/legacy/"frame" entities always normalize-in-place with
        # deprecated techniques.. so they only need 1 of the 3 exposures

        def initialize st
          @__native_association_stream = st
        end

        def flush_injection_for_full_extroverted_traversal o, n11n

          proto = LEGACY_ENTITY_ALGORITHM_ValueNormalizer___.new n11n

          o.extroverted_association_normalizer = -> native_asc do

            proto.invoke native_asc
          end

          o.extroverted_association_stream =
            remove_instance_variable( :@__native_association_stream )
          NIL
        end
      end

      # ~

      class BuildMemberBasedAssociationSource___

        # meh.

        def initialize
          @association_is_required_by = nil
        end

        attr_writer(
          :association_is_required_by,
          :member_array,
        )

        def flush_injection_for_argument_traversal o, n11n
          _st = _flush_to_normal_association_stream
          Common_flush_injection_for_argument_traversal__[ o, _st, n11n ]
        end

        def flush_injection_for_remaining_extroverted o, n11n
          Common_flush_injection_for_extroverted_tail__[ o, n11n ]
        end

        def flush_injection_for_full_extroverted_traversal o, n11n
          _st = _flush_to_normal_association_stream
          Common_flush_injection_for_full_extroverted_traversal__[ o, _st, n11n ]
        end

        def _flush_to_normal_association_stream

          is_req = remove_instance_variable :@association_is_required_by

          # (when the above is a function that produces true, #spot1-3)

          is_req ||= MONADIC_EMPTINESS_  # by default, "members" are not required

          _st = Stream_.call remove_instance_variable :@member_array do |sym|

            NormalAssociation___.new is_req[ sym ], sym
          end

          _st  # hi. #todo
        end

        def use_this_noun_lemma_to_mean_attribute
          "member"
        end
      end

      # ~

      class NormalAssociationStreamBasedAssociationSource___

        def initialize st
          @__association_stream = st
        end

        # ~ ( begin copy paste

        def flush_injection_for_argument_traversal o, n11n
          _st = _flush_to_normal_association_stream
          Common_flush_injection_for_argument_traversal__[ o, _st, n11n ]
        end

        def flush_injection_for_remaining_extroverted o, n11n
          Common_flush_injection_for_extroverted_tail__[ o, n11n ]
        end

        def flush_injection_for_full_extroverted_traversal o, n11n
          _st = _flush_to_normal_association_stream
          Common_flush_injection_for_full_extroverted_traversal__[ o, _st, n11n ]
        end

        # ~ )

        def _flush_to_normal_association_stream
          remove_instance_variable :@__association_stream
        end

        def use_this_noun_lemma_to_mean_attribute
          USE_WHATEVER_IS_DEFAULT_
        end
      end

      # ~

      Common_flush_injection_for_full_extroverted_traversal__ = -> o, asc_st, n11n do

        # (this *could* be tightened up with the next one but meh)

        Common_flush_injection_for_extroverted_tail__[ o, n11n ]

        a = []

        begin
          asc = asc_st.gets
          asc || break
          Association_is_extroverted__[ asc ] || redo
          a.push asc
          redo
        end while above

        o.extroverted_association_stream = Stream_[ a ]

        NIL
      end

      Common_flush_injection_for_argument_traversal__ = -> o, asc_st, n11n do

        # (member-based is basically a layer on top of stream-based)

        h = {} ; pool = {}

        begin
          asc = asc_st.gets
          asc || break
          if Association_is_extroverted__[ asc ]
            pool[ asc.name_symbol ] = true
          end
          h[ asc.name_symbol ] = asc
          redo
        end while above

        mutable_argument_value_pipeline = MutableArgumentValuePipeline___.new n11n

        o.argument_value_parser = -> normal_asc do
          mutable_argument_value_pipeline.reinitialize normal_asc
          ok = mutable_argument_value_pipeline.execute
          if ok
            pool.delete normal_asc.name_symbol  # #here12
          end
          ok  # hi. #todo
        end

        o.did_you_mean_by = -> do  # :#here10
          a = h.keys - mutable_argument_value_pipeline.__to_seen_keys_
          if a.length.zero?
            h.keys
          else
            a
          end
        end

        o.association_soft_reader = h.method :[]

        o.extroverted_diminishing_pool = pool ; nil
      end

      Common_flush_injection_for_extroverted_tail__ = -> o, n11n do

        # (exacty as in the pseudocode in [#012])

        mutable_extroverted_association_pipeline = MutableExtrovertedAssociationPipeline___.new n11n

        o.extroverted_association_normalizer = -> normal_asc do

          mutable_extroverted_association_pipeline.reinitialize normal_asc
          _ok = mutable_extroverted_association_pipeline.execute
          _ok  # #hi. #todo
        end

        NIL
      end

      # ==

      ArgumentTraversalInjection___ = ::Struct.new(
        :argument_value_parser,
        :association_soft_reader,
        :did_you_mean_by,
        :extroverted_diminishing_pool,
      )

      RemainingExtrovertedTraversalInjection___ = ::Struct.new(
        :extroverted_association_normalizer,
      )

      FullExtrovertedTraversalInjection___ = ::Struct.new(
        :extroverted_association_normalizer,
        :extroverted_association_stream,
      )

      # ==

      NormalAssociation___ = ::Struct.new :is_required, :name_symbol do

        alias_method :intern, :name_symbol

        def default_by
          NOTHING_
        end

        def normalize_by
          NOTHING_
        end

        def is_flag
          FALSE
        end

        def is_glob
          FALSE
        end
      end

      # ==

      Association_is_extroverted__ = -> asc do  # :#here11
        asc.is_required || asc.default_by || asc.normalize_by
      end

      # ==

      # the next two classes are meant to correspond nearly exactly
      # to pseudocode in [#012]

      CommonPipelineLanguage__ = ::Module.new

      class MutableArgumentValuePipeline___

        include CommonPipelineLanguage__

        def initialize n11n

          @_seen = {}
          super
        end

        def reinitialize asc
          @normal_association = asc ; nil
        end

        def execute

          ok = true
          ok &&= __resolve_unsanitized_value
          ok &&= __check_clobber

          ok and if __unsanitized_value_qualifies_as_existent

            if ad_hoc_normalizer_exists

              if resolve_sanitized_value_through_ad_hoc_normalizer
                send_sanitized_value
              else
                UNABLE_
              end
            else
              send_unsanitized_value
            end

          elsif defaulting_exists

            if resolve_sanitized_value_through_defaulting
              send_sanitized_value
            else
              send_unsanitized_value  # (which is nil)
            end

          elsif ad_hoc_normalizer_exists

            if resolve_sanitized_value_through_ad_hoc_normalizer
              send_sanitized_value
            else
              UNABLE_
            end
          else

            send_unsanitized_value  # (which is nil)
          end
        end

        def __resolve_unsanitized_value
          kn = @_callbacks_.__resolve_unsanitized_value_for_ @normal_association
          if kn
            @_unsanitized_value_ = kn.value_x ; ACHIEVED_
          end
        end

        def __unsanitized_value_qualifies_as_existent

          Value_qualifies_as_existent__[ @_unsanitized_value_ ]
        end

        def __check_clobber
          k = @normal_association.name_symbol
          if @_seen[ k ]
            if @normal_association.is_glob
              ACHIEVED_  # :[#008.2] #borrow-coverage from [sn]
            else
              self._COVER_ME__this_is_supposed_to_be_not_OK__
            end
          else
            @_seen[ k ] = true ; true
          end
        end

        def __to_seen_keys_
          @_seen.keys
        end
      end

      # ~

      class MutableExtrovertedAssociationPipeline___

        # the second of two "pipelines". process the "extroverted tail":

        # created lazily one-per-invocation IFF there is one or more
        # remaining extroverted associations in the diminishing pool after
        # processing (any) arguments.

        # (during refactoring this code-interest moved here, but to preserve
        # VCS history (for now) the comment-block describing its sub-
        # algorithm in detail is still at #here9 above.)

        include CommonPipelineLanguage__

        def reinitialize normal_asc
          @normal_association = normal_asc
        end

        def execute

          if __the_valid_value_store_already_has_an_existent_value

            ACHIEVED_

          elsif defaulting_exists && resolve_sanitized_value_through_defaulting

            send_sanitized_value

          elsif ad_hoc_normalizer_exists

            # FOR NOW for compatibility with the past
            # (#borrow-coverage :[#008.10]:)
            # and perhaps into the future, ad-hoc normalizers can be used
            # for defaulting too:

            if __resolve_sanitized_value_via_ad_hoc_normalizer_against_NOTHING

              send_sanitized_value
            else
              UNABLE_
            end

          elsif __field_is_required

            @_sanitized_value_ = nil
            send_sanitized_value   # anticipate the failure on required check

          else
            ACHIEVED_  # nothing to send
          end
        end

        def __the_valid_value_store_already_has_an_existent_value

          _x = simplified_read
          Value_qualifies_as_existent__[ _x ]
        end

        def __field_is_required
          @normal_association.is_required
        end
      end

      # ~

      module CommonPipelineLanguage__

        def initialize n11n  # eek/meh

          @_callbacks_ = n11n
          @_valid_value_store_ = n11n.valid_value_store
          # (weird-looking ivar names explained at [#bs-032.1.1])
        end

        def resolve_sanitized_value_through_defaulting  # assume defaulting exists

          # exactly as documented, allow that defaulting can fail

          _kn_by = @normal_association.default_by
          a = @_callbacks_.arguments_to_default_proc_by[ @normal_association.name_symbol ]
          p = a.pop
          kn = _kn_by[ * a, & p ]
          if kn
            @_sanitized_value_ = kn.value_x ; true
          end
        end

        def defaulting_exists
          @normal_association.default_by
        end

        def ad_hoc_normalizer_exists
          @normal_association.normalize_by
        end

        def __resolve_sanitized_value_via_ad_hoc_normalizer_against_NOTHING  # 1x but here for proximity to next

          _qkn = Common_::QualifiedKnownness.via_association @normal_association
          _resolve_sanitized_value_through_ad_hoc_normalizer_CL _qkn
        end

        def resolve_sanitized_value_through_ad_hoc_normalizer

          # :[#008.11] #borrow-coverage from [sn] NOTE we should really cover this

          # (here we squash the knowlege of whether the ivar was actually set)

          _x = remove_instance_variable :@_unsanitized_value_
          _qkn = Common_::QualifiedKnownness[ _x, @normal_association ]
          _resolve_sanitized_value_through_ad_hoc_normalizer_CL _qkn
        end

        def _resolve_sanitized_value_through_ad_hoc_normalizer_CL _qkn
          kn = @normal_association.normalize_by[ _qkn, & @_callbacks_.listener ]
          if kn
            if kn.is_known_known
              @_sanitized_value_ = kn.value_x
            else
              @_sanitized_value_ = nil  # our indifference. [sn]
            end
            ACHIEVED_
          else
            kn
          end
        end

        def send_sanitized_value
          _check_and_write_value_appropriately_CL remove_instance_variable :@_sanitized_value_
        end

        def send_unsanitized_value
          _check_and_write_value_appropriately_CL remove_instance_variable :@_unsanitized_value_
        end

        def _check_and_write_value_appropriately_CL x

          if @normal_association.is_glob

            if @normal_association.is_required

              NOTHING_  # :[#008.13]: #borrow-coverage from [sn]
            end

            a = simplified_read
            if a
              a.concat x
            else
              simplified_write x
            end
            ACHIEVED_

          elsif @normal_association.is_required && ! Value_qualifies_as_existent__[ x ]

            @_callbacks_.add_missing_required_MIXED_association_ @normal_association.name_symbol

            KEEP_PARSING_  # if we stopped now we wouldn't have [#012.J.2] aggregation
          else
            simplified_write x
            ACHIEVED_  # it must be that writes can never fail. this is convenience
          end
        end

        def simplified_write x
          @_valid_value_store_.simplified_write_ x, @normal_association.name_symbol
        end

        def simplified_read
          @_valid_value_store_.simplified_read_ @normal_association.name_symbol
        end
      end

      # ==

      # -  # (re-open for those parts that support the "pipelines" above)

        # -- D: resolving an unsanitized value (mostly moved to adapters)

        def __resolve_unsanitized_value_for_ normal_asc
          @_my_arg_scanner._match_unsanitized_value_ normal_asc
        end

        # -- C: matching the argument scanner head against an association

        def __when_primary_not_found  # :#here4 lazily detect callbacks

          # in order to assimilate parts of our very old "attributes actor"
          # API, allow that the client might define this idiomatic method

          if instance_variable_defined? :@entity
            if @entity.respond_to? :when_after_process_iambic_fully_stream_has_content
              _yes = true
            end
          end
          if _yes
            ::Kernel._NO_PROBLEM__but_cover_me__
            user_x = @entity.when_after_process_iambic_fully_stream_has_content argument_scanner
            if user_x
              self._EEK
              _unable
            else
              user_x  # false or nil
            end
          else
            __when_primary_not_found_express_event_somehow
          end
        end

        def __when_primary_not_found_express_event_somehow

          ev_early_to_be_safe = __build_primary_not_found_event  # for now NOTE

          # like #here2, some of these are and some of these aren't like this

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

        def __build_primary_not_found_event

          p = @__did_you_mean_by
          if p
            _did_you_mean = p[]  # perhaps #here10
          end
          _these = _maybe_special_noun_lemma

          _ev = Home_::Events::Extra.with(
            :unrecognized_token, _unsanitized_key,
            :did_you_mean_tokens, _did_you_mean,
            * _these,
          )
          _ev  # hi. #todo
        end

        def _maybe_special_noun_lemma

          # { :attribute | :member | :parameter | :primary | :property | :field }

          s = @association_source.use_this_noun_lemma_to_mean_attribute
          if s
            [ :noun_lemma, s ]
          end
        end

        def _association_key
          @_current_normal_association.name_symbol
        end

        def _unsanitized_key
          @_my_arg_scanner._unsanitized_key_
        end

        def _unable
          # (we used to set `@_ok` to false but we want to avoid that)
          UNABLE_
        end

        # -- B: final result

        def __result_in_entity
          # the "proper" result for a parsing performer is T/F ("keep parsing")
          # but it's convenient for some clients to have the result be this:
          remove_instance_variable :@entity
        end

        def __result_in_self
          freeze  # oldschool [ta] techniques
        end

        def __result_normally
          KEEP_PARSING_
        end

        # -- A: support

        def valid_value_store
          send @__valid_value_store
        end

        def __valid_value_store
          @__valid_value_store_object
        end

        attr_reader(
          :arguments_to_default_proc_by,  # here, 1x
          :association_source,  # [ta]
          :entity,
          :listener,  # because #here8
        )
      # -

      # ==

      # ~

      class LEGACY_ENTITY_ALGORITHM_ValueNormalizer___

        # this legacy algorithm either violates or fails to recognize:
        #
        #   - [#012.E.2] defaulting must be able to fail
        #   - [#012.5.2] don't run default values thru ad-hoc normalizers
        #   - [#012.5.3] don't normalize values already in the value store
        #
        # [br] uses the entity as an UNSANITIZED value store. this is
        # something baked deeply into the [br] stack. we could try and "fix"
        # that to achieve maximum "one ring"-ness, but since [br]-era
        # entities and actions are going away "soon" anyway, for now we just
        # corral it all into here.

        def initialize o
          @entity = o.entity
          @_callbacks = o
        end

        def invoke asc
          dup.__init( asc ).execute
        end

        def __init asc
          @native_association = asc ; self
        end

        def execute
          _store :@_existing_knownness, @entity._read_knownness_( @native_association ) or self._NEVER
          if __normalize_value
            __maybe_send_value
            ACHIEVED_
          else
            UNABLE_
          end
        end

        def __maybe_send_value

          if @_existing_knownness.is_known_known
            if @_new_knownness.is_known_known
              if @_existing_knownness.object_id == @_new_knownness.object_id
                NOTHING_  # hi. #covered
              else
                _write
              end
            else
              self._COVER_ME__became_unknown__
            end
          elsif @_new_knownness.is_known_known
            _write
          end
          NIL
        end

        def _write
          @entity._write_via_association_ @_new_knownness.value_x, @native_association
          NIL
        end

        def __normalize_value  # :#here1

          kn = @_existing_knownness ; asc = @native_association

          # -

            # 1. if value is unknown and defaulting is available, apply it.

            if ! kn.is_effectively_known && Home_::Has_default[ asc ]

              # in violation of [#012.E.2], the below should but does not
              # make accomodations for the remote client (API) to express
              # that it failed to resolve a default value.

              _x = asc.default_value_via_entity__ @entity
              kn = Common_::KnownKnown[ _x ]
              did = true
            end

            # (it may be that you don't know the value and there is no default)

            # 2. if there are ad-hoc normalizations, apply those. (was [#ba-027])

            bx = asc.ad_hoc_normalizer_box
            if bx
              if did
                # :[#008.6]: #borrow-coverage from [br], [cu].
                # cases like these need to GO AWAY #here3 because they are
                # in violation of [#012.5.2]
                NOTHING_  # hi.
              end
              kn = __add_hocs kn, bx
            end

            # 3. if this is a required property and it is unknown, act.
            #    (skip this if the field failed a normalization above.)

            if kn

              if ! kn.is_effectively_known && Home_::Is_required[ asc ]

                kn = __receive_missing_required kn
              end
            end

            # -
          _store :@_new_knownness, kn
        end

        def __receive_missing_required kn  # #coverpoint1.8

          @_callbacks.add_missing_required_MIXED_association_ @native_association

          kn  # don't stop cold on these - aggregate and procede
        end

        def __add_hocs kn, bx

          # ad-hocs need to know the property too (née "trios not pairs")

          bx.each_value do |norm_norm_p|

            # at each step, value might have changed. [#053]

            _qkn = kn.to_qualified_known_around @native_association

            kn = norm_norm_p[ _qkn, & _listener ]  # (was [#072])
            kn or break
            kn.is_qualified and self._SHAPE_ERROR_we_want_QKNs_in_and_KNs_out
          end

          kn
        end

        def _listener
          @_callbacks.listener  # :#here8
        end

        define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
      end

      # ==

      MyScanner__ = ::Class.new

      class ComplexArgScanner___ < MyScanner__

        def initialize scn
          @_ick = nil ; super
        end

        def _scan_primary_symbol_
          @native_argument_scanner.scan_primary_symbol
        end

        def _unsanitized_key_
          @native_argument_scanner.current_primary_symbol
        end

        def _match_unsanitized_value_ normal_asc

          remove_instance_variable :@_ick

          if normal_asc.is_glob
            @_eew = false
            a = @native_argument_scanner.scan_glob_values
            if a
              Common_::KnownKnown[ a ]
            end

          elsif normal_asc.is_flag
            @_eew = false
            @native_argument_scanner.scan_flag_value
          else

            @_eew = true
            unsanitized_value = nil
            _ok = @native_argument_scanner.map_value_by do |x|
              unsanitized_value = x ; true
            end
            if _ok
              Common_::KnownKnown[ unsanitized_value ]
            end
          end
        end

        def _when_primary_completed_

          # we hate this, but for now, meh: [#ze-052.2] be OCD about don't
          # advance until valid, but only for certain argument arities.
          @_ick = nil
          if remove_instance_variable :@_eew
            @native_argument_scanner.advance_one ; nil
          end
        end
      end

      # ~

      class SimpleArgScanner___ < MyScanner__

        def initialize scn
          @native_argument_scanner = scn
        end

        def _scan_primary_symbol_
          # simple scanners do not have special parsing to detect tokens
          # that look like primaries. leave the scanner as-is. follow [#012.L.1]
          TRUE
        end

        def _unsanitized_key_
          @native_argument_scanner.head_as_is
        end

        def _match_unsanitized_value_ normal_asc

          # if the scanner ends "early" then the below just fails hard. there
          # is no special emission for this if you're using a simple scanner.

          if normal_asc.is_glob
            ::Kernel._CANNOT_PARSE_THIS__with_simple_scanner__
          elsif normal_asc.is_flag
            ::Kernel._CANNOT_PARSE_THIS__with_simple_scanner__
          else
            scn = @native_argument_scanner
            scn.advance_one  #advance past the primary name,
            x = scn.head_as_is
            scn.advance_one  # and EEK [#012.L.1] do this too
            Common_::KnownKnown[ x ]
          end
        end

        def _when_primary_completed_
          NOTHING_  # :[#012.L.1]: CHANGED
        end

        attr_reader :native_argument_scanner
      end

      class MyScanner__

        def initialize scn
          @native_argument_scanner = scn
        end

        def __no_more_arguments_
          @native_argument_scanner.no_unparsed_exists
        end

        attr_reader :native_argument_scanner
      end

      # ==

      Value_qualifies_as_existent__ = -> x do

        # (keep in mind - every occurrence where this is called, we might
        #  swap it out with a call to the normalization invocation (as "callbacks"))

        if x  # imagine ::BasicObject
          TRUE
        elsif x.nil?
          FALSE  # hi.
        else
          self._COVER_ME__meaningful_false__
          TRUE  # meaningful false. hi.
        end
      end

      # ==

      # ~

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

        def simplified_write_ x, k
          @__write_by[ k, x ]
          NIL
        end

        def simplified_read_ k
          @__read_by[ k ]
        end
      end

      # ==

      module THE_EMPTY_SIMPLIFIED_VALID_VALUE_STORE___ ; class << self

        def read_softly_via_association asc
          NIL
        end
      end ; end

      # ==

      MONADIC_TRUTH_ = -> _ { true }
      UNDERSCORE_ = '_'
      USE_WHATEVER_IS_DEFAULT_ = nil

      # ==
    # -
  end
end
# #history-037.5.C - the "FUN" methods and more "association index"-related, 1st pass
# #history-037.5.I - experimental assimilation of the facility from "association index"
# #history-037.5.G - "normalization against model" (file assimilated)
