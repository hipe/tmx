module Skylab::Fields

  class CommonAssociation < SimplifiedName  # :[#039].

    # this file holds both the "entity killer" association class and also
    # the older (but widespread) "common association".

      # (see [#002.C] 'pertinent ideas around "attributes actors" and related')

      # ==

      class EntityKillerParameter < Common_::SimpleModel

        define_singleton_method :grammatical_injection, ( Lazy_.call do

          mod = Home_::CommonAssociationMetaAssociations_::EntityKillerModifiers

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

      include AssociationValueProducerConsumerMethods_

      def initialize k

        @parameter_arity_is_known = false  # [#002.4] "weirdness .."
        @_parameter_arity = :__raise_that_parameter_arity_is_unknown

        @argument_arity = :one  # by default, attributes take one argument

        @_write_parameter_arity_once = :__write_parameter_arity_once

        init_association_value_producer_consumer_ivars_

        super  # yields self
      end

      def dup_by & edit_p

        # NOTE is ad-hoc for "one place in [ze]" - VERY sketchy. the block
        # idiom is different than above: here we are expected to write to
        # ivars directly (FOR NOW) #experimental

        otr = dup  # see super
        otr.instance_exec( & edit_p )
        otr.__orig_freeze
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

      alias_method :__orig_freeze, :freeze
      def freeze
        remove_instance_variable :@_write_parameter_arity_once
        close_association_value_producer_consumer_mutable_session_
        NIL
      end

      # --

      def as_association_write_into_against ent, scn  # result in kp. #coverpoint1.3, [hu]

        Home_::Normalization.call_by do |o|
          o.argument_scanner = scn
          o.entity = ent
          o.execute_by__ = -> n11n, & p do
            as_association_interpret_ n11n, & p  # hi. #todo
          end
        end
      end

      def as_association_normalize_in_place_ n11n  # stay close to 'def as_association_interpret_`

        _dsl = Home_::Interpretation_::ArgumentValueInterpretation_DSL.new self, n11n
        _dsl.__as_DSL_flush_commonly_for_normalize_in_place_
      end

      attr_writer(
        :argument_arity,
      )

      attr_reader(
        :argument_arity,
        :default_proc,
        :description_proc,
        :parameter_arity_is_known,
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

      # ==
    # ==
    # ==
  end
end
# #tombstone-A: moved what's now "argument value producer consumer" up & out
