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
          o.lookup = idx.lookup_attribute_proc_
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

        attr_writer(
          :argument_scanner,
          :arguments_to_default_proc_by,
          :read_by,
          :write_by,
          :formal_attribute_stream,
          :listener,
        )

        def execute

          __index_formals

          until __no_more_arguments

            __match_argument_scanner_head_against_formals || break

            __resolve_unsanitized_value_for_this_primary || break

            __maybe_check_clobber || break

            __resolve_sanitized_value_via_unsanitized_value || break

            _maybe_check_required_and_maybe_send
          end

          @_ok && __run_the_remains_of_the_diminishing_pool
          @_ok && __check_if_there_were_any_missing_requireds
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
            @_formal_attribute_via_name_symbol.fetch k
          end

          _ev = Home_::Events::Missing.new_with(

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

          until __no_more_formals_in_diminishing_pool

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
          _qkn = Common_::QualifiedKnownness.via_association @_current_formal_attribute
          _resolve_sanitized_value_via_ad_hoc_normalizer _qkn
        end

        def __the_property_store_already_has_an_existent_value

          _x = @read_by[ _sanitized_key ]
          _qualifies_as_existent _x
        end

        def __no_more_formals_in_diminishing_pool

          if @_diminishing_pool_key_scanner.no_unparsed_exists
            @_current_formal_attribute = nil  # #not-taking-any-chances
            remove_instance_variable :@_current_formal_attribute
            remove_instance_variable :@_diminishing_pool_key_scanner ; true
          else
            _k = @_diminishing_pool_key_scanner.gets_one
            @_current_formal_attribute = @_formal_attribute_via_name_symbol[_k]
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

          @write_by[ _sanitized_key, x ]

          _yes = remove_instance_variable :@_do_advance_EEW
          _yes && @argument_scanner.advance_one
          NIL
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
          @_current_formal_attribute.is_required
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
            __resolve_sanitized_value_via_ad_hoc_normalizer_against_something
          else
            __use_the_unsanitized_value_as_the_sanitized_value_YIKES
          end
        end

        def __resolve_sanitized_value_via_ad_hoc_normalizer_against_something

          # #borrow-coverage from [#sn-008.2], use E.K prop as an "association" in a qkn

          _x = remove_instance_variable :@_current_unsanitized_value
          _qkn = Common_::QualifiedKnownness[ _x, @_current_formal_attribute ]  # NOTE RIDE
          _resolve_sanitized_value_via_ad_hoc_normalizer _qkn
        end

        def __use_the_unsanitized_value_as_the_sanitized_value_YIKES

          _x = remove_instance_variable :@_current_unsanitized_value
          @_current_sanitized_value = _x ; true
        end

        def _resolve_a_default_value
          kn_by = @_current_formal_attribute.default_by
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
          @_current_formal_attribute.normalize_by
        end

        def _resolve_sanitized_value_via_ad_hoc_normalizer qkn

          kn = @_current_formal_attribute.normalize_by[ qkn, & @listener ]

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
              self._COVER_ME__this_is_supposed_to_be_OK__
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

            ::Kernel._COVER_ME__resolve_unsanitized_vaue_for_glob__

          elsif _is_flag

            ::Kernel._COVER_ME__resolve_unsanitized_vaue_for_flag__

          else
            @argument_scanner.map_value_by do |x|
              @_do_advance_EEW = true
              ok = true ; unsanitized_value = x ; nil
            end
          end

          if ok
            @_current_unsanitized_value = unsanitized_value ; true
          else
            _unable
          end
        end

        def _is_flag
          @_current_formal_attribute.is_flag
        end

        def _is_glob
          @_current_formal_attribute.is_glob
        end

        # -- C

        def __match_argument_scanner_head_against_formals

          if @argument_scanner.scan_primary_symbol

            fo = @_formal_attribute_via_name_symbol[ _unsanitized_key ]
            if fo
              @_current_formal_attribute = fo ; true
            else
              __when_primary_not_found
            end
          else
            _unable
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

          _did_you_mean = @_formal_attribute_via_name_symbol.keys

          _ev = Home_::Events::Extra.build [ _unsanitized_key ], _did_you_mean

          _ev  # hi. #todo
        end

        def _sanitized_key
          @_current_formal_attribute.name_symbol
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

          if instance_variable_defined? :@argument_scanner and
              @argument_scanner and
              ! @argument_scanner.no_unparsed_exists

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

        def __index_formals

          diminishing_pool = {} ; h = {}

          st = remove_instance_variable :@formal_attribute_stream

          begin
            fo = st.gets
            fo || break

            if fo.is_required || fo.default_by || fo.normalize_by
              diminishing_pool[ fo.name_symbol ] = true
            end

            h[ fo.name_symbol ] = fo

            redo
          end while above

          @_diminishing_pool = diminishing_pool
          @_formal_attribute_via_name_symbol = h
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
