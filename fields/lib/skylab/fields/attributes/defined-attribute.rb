module Skylab::Fields

  class Attributes

    class DefinedAttribute < SimplifiedName  # :[#039].

      # (see [#002.C] 'pertinent ideas around "attributes actors" and related')

      # ==

      class EntityKillerParameter < Common_::SimpleModel

        define_singleton_method :grammatical_injection, ( Lazy_.call do

          mod = Attributes::MetaAttributes::EntityKillerModifiers

          Home_.lib_.parse::IambicGrammar::ItemGrammarInjection.define do |o|

            o.item_class = self
            o.prefixed_modifiers = mod::PrefixedModifiers
            o.postfixed_modifiers = mod::PostfixedModifiers
          end
        end )

        def will_describe_by_this p
          send ( @_receive_description ||= :__receive_1st_description ), p
        end

        def __receive_1st_description p
          @_receive_description = :_CLOSED
          @describe_by = p ; KEEP_PARSING_
        end

        def receive_argument_moniker sym  # :[#008.4]: #borrow-coverage from [sn]  (implementation in progress)
          @ARGUMENT_MONIKER_SYMBOL = sym ; KEEP_PARSING_
        end

        def must_be_integer_greater_than_or_equal_to_this d
          _add_number_normalization :number_set, :integer, :minimum, d
        end

        def _add_number_normalization * x_a  # (as seen in [br])

          normer = Home_.lib_.basic.normalizers.number.via_iambic x_a
          will_normalize_by do |qkn, &p|
            if qkn.is_effectively_known
              normer.normalize_qualified_knownness qkn, & p
            else
              qkn.to_knownness
            end
          end
        end

        def will_normalize_by & p
          send ( @_receive_normalizer ||= :__receive_1st_normalizer ), p
        end

        def __receive_1st_normalizer p
          @_receive_normalizer = :_CLOSED
          @normalize_by = p ; KEEP_PARSING_
        end

        # --

        def will_default_by & p
          send ( @_receive_default ||= :__receive_1st_default ), p
        end

        def __receive_1st_default p
          @_receive_default = :_CLOSED
          @default_by = p ; KEEP_PARSING_
        end

        # --

        def become_required
          @is_required = true ; ACHIEVED_
        end

        def become_flag
          _argument_arity_mutex :@is_flag
        end

        def become_glob
          _argument_arity_mutex :@is_glob
        end

        def _argument_arity_mutex ivar
          send ( @_receive_arg_arity ||= :__receive_1st_arg_arity ), ivar
        end

        def __receive_1st_arg_arity ivar
          @_receive_arg_arity = :_CLOSED
          instance_variable_set ivar, true ; KEEP_PARSING_
        end

        def accept_name_symbol sym
          @name_symbol = sym
        end

        def finish
          # (or not:)
          freeze ; nil
        end

        def id2name
          name_symbol  # :#coverpoint1.2
        end

        attr_reader(
          :default_by,
          :describe_by,
          :normalize_by,
          :is_flag, :is_glob,
          :is_required,
          :name_symbol,
        )
      end

      # ==
      # ==
      # ==

      def initialize k, & edit_p

        @parameter_arity_is_known = false
        @_parameter_arity = :__raise_that_parameter_arity_is_unknown

        # when a parameter arity ("required-ness") is not defined explicitly
        # (e.g `optional` signifies a parameter arity of `zero_or_one`),
        # then the default value we are to interpret for it depends on
        # whether any attributes in the set defined themselves as optional:
        # if none did then all are optional; if any did then only those that
        # did are optional and the rest are required!

        @argument_arity = :one  # by default, attributes take one argument

        __init_temporary_ivars
        super k do |me|
          edit_p[ me ]
        end
      end

      def dup_by & edit_p

        # NOTE is ad-hoc for "one place in [ze]" - VERY sketchy. the block
        # idiom is different than above: here we are expected to write to
        # ivars directly (FOR NOW) #experimental

        otr = dup  # see super
        otr.instance_exec( & edit_p )
        otr.__orig_freeze
      end

      def __init_temporary_ivars

        @_write_parameter_arity_once = :__write_parameter_arity_once
        @_pending_meths_definers = nil

        @_receive_interpreterer = :__receive_interpreterer
        @_receive_readerer = :__receive_readerer
        @_receive_writerer = :__receive_writerer

        @_read_by_by = nil
        @_write_by_by = nil
        @_interpret_by_by = nil
      end

      # -- be normalizant

      def be_optional__
        _become_optional_once
        NIL_
      end

      def be_defaultant_by_value__ x
        # ..
        be_defaultant_by_ do
          x
        end
      end

      def be_defaultant_by_ & p
        _become_optional_once
        @default_proc = p
        NIL_
      end

      # -- required-ness

      def _become_optional_once
        _write_parameter_arity_once :zero_or_one
      end

      def be_required__
        _write_parameter_arity_once :one
      end

      def _write_parameter_arity_once sym
        send @_write_parameter_arity_once, sym
      end

      alias_method :parameter_arity=, :_write_parameter_arity_once

      def __write_parameter_arity_once sym
        @_write_parameter_arity_once = :__FIX_REDUNDANT_WRITES_TO_PARAM_ARITY
        @parameter_arity_is_known = true
        @_parameter_arity = :__parameter_arity
        @__parameter_arity = sym
      end

      def parameter_arity
        send @_parameter_arity
      end

      def __raise_that_parameter_arity_is_unknown
        raise StateError_, "unknown. check `parameter_arity_is_known` first"
      end

      def __parameter_arity
        @__parameter_arity  # hi.
      end

      # --

      def accept_description_proc__ p

        if instance_variable_defined? :@description_proc
          self._MULTIPLE_DESCRIPTIONS
        end

        @description_proc = p ; nil
      end

      def __add_methods_definer atr_p
        ( @_pending_meths_definers ||= [] ).push atr_p ; nil
      end

      def will_interpret_by_ & p
        send @_receive_interpreterer, p
      end

      def reader_by_ & p
        send @_receive_readerer, p
      end

      def writer_by_ & p
        send @_receive_writerer, p
      end

      def __receive_interpreterer p
        @_receive_interpreterer = :_closed
        @_receive_readerer = :_closed
        @_receive_writerer = :_closed
        @_interpret_by_by = p ; nil
      end

      def __receive_readerer p
        @_receive_interpreterer = :_closed
        @_receive_readerer = :_closed
        @_read_by_by = p ; nil
      end

      def __receive_writerer p
        @_receive_interpreterer = :_closed
        @_receive_writerer = :_closed
        @_write_by_by = p ; nil
      end

      alias_method :__orig_freeze, :freeze
      def freeze

        p_a = remove_instance_variable :@_pending_meths_definers
        if p_a
          @deffers_ = p_a.map do | p |
            p[ self ]
          end.freeze
        end

        remove_instance_variable :@_receive_interpreterer
        remove_instance_variable :@_receive_readerer
        remove_instance_variable :@_receive_writerer
        remove_instance_variable :@_write_parameter_arity_once

        interpret_by_by = remove_instance_variable :@_interpret_by_by

        if interpret_by_by
          remove_instance_variable :@_read_by_by
          remove_instance_variable :@_write_by_by
          @__interpret_by = interpret_by_by[ self ]
          @_flush_DSL = :__flush_DSL_customly
        else
          r_p = remove_instance_variable :@_read_by_by
          w_p = remove_instance_variable :@_write_by_by
          @_read_by = r_p ? r_p[ self ] : Read___
          @_write_by = w_p ? w_p[ self ] : Write___
          @_flush_DSL = :__flush_DSL_commonly
        end

        super
      end

      # --

      def write ent, scn  # result in kp. #coverpoint1.3 (also)

        Here_::Normalization.call_by do |o|
          o.argument_scanner = scn
          o.entity = ent
          o.execute_by__ = -> n11n, & p do
            as_association_interpret_ n11n, & p  # hi. #todo
          end
        end
      end

      def as_association_interpret_ n11n, & p
        _dsl = Interpretation_DSL__.new p, self, n11n
        flush_DSL_for_interpretation_ _dsl
      end

      def flush_DSL_for_interpretation_ dsl  # 3x in [fi]

        send @_flush_DSL, dsl
      end

      def __flush_DSL_customly dsl  # result in kp

        dsl.calculate( & @__interpret_by )
      end

      def __flush_DSL_commonly dsl  # result in kp

        dsl.__as_DSL_flush_commonly_for_interpretation_
      end

      def as_association_normalize_in_place_ n11n

        _dsl = Interpretation_DSL__.new self, n11n
        _dsl.__as_DSL_flush_commonly_for_normalize_in_place_
      end

      attr_writer(
        :argument_arity,
      )

      attr_reader(
        :argument_arity,
        :deffers_,
        :default_proc,
        :description_proc,
        :_read_by,
        :parameter_arity_is_known,
        :_write_by,
      )

      def argument_argument_moniker  # see [br]
        NOTHING_
      end

      def singplur_category_of_association  # [ac] n11n compat
        NOTHING_
      end

      def is_provisioned  # a [ze] thing, near defaulting
        false
      end

      Read___ = -> do
        # [#012.L.1] *DO* advance. (eager parsing)
        argument_scanner.gets_one
      end

      Write___ = -> x, _ do
        write_association_value_ x
      end

      # ==

      class Interpretation_DSL__

        # (used, for example, at #spot-1-4)

        def initialize listener=nil, asc, n11n
          @_argument_scanner = nil
          @_association = asc
          @__listener = listener
          @_normalization = n11n
          # for now, don't freeze only because #this-1
        end

        def mutate_for_redirect_ x, asc  # :#this-1 is why we didn't freeze
          @_argument_scanner = Argument_scanner_via_value[ x ]
          @_association = asc ; nil
        end

        # -- facility "C" replacement

        def __as_DSL_flush_commonly_for_interpretation_  # result in kp

          x = calculate( & @_association._read_by )

          if x.nil? && _defaulting_exists
            x = _default_value_that_hopefully_didnt_fail  # :#coverpoint1.9
          end

          calculate x, @__listener, & @_association._write_by
        end

        def __as_DSL_flush_commonly_for_normalize_in_place_  # result in kp

          if __any_stored_value_is_effectively_nil

            if _defaulting_exists
              __change_working_value_to_default_value
            end

            # (no ad-hoc normalization (why?))

            __maybe_write
          else
            KEEP_PARSING_  # if it is set to any non-nil value, leave it alone ([#012.5.3])
          end
        end

        # -- exposures

        alias_method :calculate, :instance_exec

        def write_association_value_ x
          @_normalization.as_normalization_write_via_association_ x, @_association
          KEEP_PARSING_  # in-memory writes may not fail. provided as convenience.
        end

        def argument_scanner
          @_argument_scanner || @_normalization.argument_scanner
        end

        def current_association
          @_association
        end

        def association_index
          @_normalization.association_index
        end

        def entity
          @_normalization.entity
        end

        # -- common language for old facility "C"

        def __maybe_write

          if __is_required
            if _working_value_is_nil
              __memo_this_missing_required_association
            else
              _write
            end
          elsif _working_value_is_nil
            if ! @__was_defined
              _write  # [#012.J.4] nilify
            end
          else
            _write
          end

          KEEP_PARSING_
        end

        def __any_stored_value_is_effectively_nil

          vvs = @_normalization.valid_value_store  # :#spot-1-2

          if vvs.knows_value_for_association @_association
            was_defined = true
            x = vvs.dereference_association @_association
          end

          if x.nil?
            @__valid_value_store = vvs
            @__was_defined = was_defined
            @_working_value = nil
            TRUE
          end
        end

        # -- defaulting

        def _defaulting_exists
          @_association.default_proc  # i.e `Has_default`
        end

        def __change_working_value_to_default_value
          # (violate [#012.E.1] (defaulting can fail) (legacy, KISS))
          @_working_value = _default_value_that_hopefully_didnt_fail
          NIL
        end

        def _default_value_that_hopefully_didnt_fail
          @_association.default_proc.call
        end

        # -- ad-hoc normalization NOTE

        # (there is no treatment of ad-hoc normalization; probably you
        #  should use method-based associations..)

        # -- requiredness

        def __is_required

          # (implementation of [#002.4] is 1x redundant)

          if @_association.parameter_arity_is_known
            Is_required[ @_association ]
          else
            @_normalization.association_index.required_is_default_
          end
        end

        def __memo_this_missing_required_association
          @_normalization.add_missing_required_MIXED_association_ @_association
          NIL
        end

        # -- support

        def _working_value_is_nil
          @_working_value.nil?
        end

        def _write
          _x = remove_instance_variable :@_working_value
          @__valid_value_store.write_via_association _x, @_association
        end

        attr_reader(
          :_normalization,
        )
      end

      # ==
    end
  end
end
