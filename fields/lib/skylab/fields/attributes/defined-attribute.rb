module Skylab::Fields

  class Attributes

    class DefinedAttribute < SimplifiedName  # :[#039].

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
          name_symbol  # :#coverpoint-1-2
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

        @argument_arity = :one
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

        @_become_optional_m = :_change_parameter_arity_to_be_optional_once
        @_pending_meths_definers = nil

        @_RW_m = :__receive_first_read_and_write_proc
        @_read_m = :__receive_first_read_proc
        @_write_m = :__receive_first_write_proc

        @_reader_p = nil
        @_writer_p = nil
        @_read_writer_p = nil
      end

      # -- be normalizant

      def be_optional__
        send @_become_optional_m
        NIL_
      end

      def be_defaultant_by_value__ x
        # ..
        be_defaultant_by_ do
          x
        end
      end

      def be_defaultant_by_ & p
        _change_parameter_arity_to_be_optional_once
        @default_proc = p
        NIL_
      end

      def _change_parameter_arity_to_be_optional_once

        @_become_optional_m = :___optionality_is_locked__is_already_optional
        @parameter_arity = :zero_or_one ; nil
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

      def read_and_writer_by__ & p
        send @_RW_m, p
      end

      def reader_by_ & p
        send @_read_m, p
      end

      def writer_by_ & p
        send @_write_m, p
      end

      def __receive_first_read_and_write_proc p
        @_read_m = :_locked
        @_RW_m = :_locked
        @_write_m = :_locked
        @_read_writer_p = p ; nil
      end

      def __receive_first_read_proc p
        @_read_m = :_locked
        @_RW_m = :_locked
        @_reader_p = p ; nil
      end

      def __receive_first_write_proc p
        @_write_m = :_locked
        @_RW_m = :_locked
        @_writer_p = p ; nil
      end

      alias_method :__orig_freeze, :freeze
      def freeze

        if :_change_parameter_arity_to_be_optional_once ==  # eek
            remove_instance_variable( :@_become_optional_m )
          @parameter_arity = :one
        end

        p_a = remove_instance_variable :@_pending_meths_definers
        if p_a
          @deffers_ = p_a.map do | p |
            p[ self ]
          end.freeze
        end

        remove_instance_variable :@_read_m
        remove_instance_variable :@_RW_m
        remove_instance_variable :@_write_m

        rw_p = remove_instance_variable :@_read_writer_p
        r_p = remove_instance_variable :@_reader_p
        w_p = remove_instance_variable :@_writer_p

        if rw_p
          @_interpret_m = :__custom_interpret
          @__rw = rw_p[ self ]
        else
          @_interpret_m = :__common_interpret
          @_read = r_p ? r_p[ self ] : Read___
          @_write = w_p ? w_p[ self ] : Write___
        end

        super
      end

      # --

      def write sess, scn  # #EXPERIMENTAL #cover-me #todo

        pa = Here_::AssociationIndex_::Parse_and_or_Normalize.new sess
        pa.argument_scanner = scn
        _interpret pa  # result is k.p
      end

      def _interpret parse, & x_p

        _args = Interpretation_Services___.new self, parse
        read_and_write_ _args, & x_p
      end

      def read_and_write_ args, & x_p  # at least 2x here

        send @_interpret_m, args, & x_p
      end

      def __common_interpret args, & x_p

        _x = args.calculate( & @_read )
        args.calculate _x, x_p, & @_write  # result is k.p
      end

      def __custom_interpret args

        args.calculate( & @__rw )  # result is k.p
      end

      attr_accessor(
        :argument_arity,
      )

      attr_reader(
        :deffers_,
        :default_proc,
        :description_proc,
        :parameter_arity,
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
        argument_scanner.gets_one
      end

      Write___ = -> x, _ do
        accept_attribute_value x
        KEEP_PARSING_
      end

      # ==

      class Interpretation_Services___

        def initialize attr, parse
          @_argument_scanner = nil
          @_formal_attribute = attr
          @_parse = parse
          # for now, don't freeze only because #this
        end

        def mutate_for_redirect_ x, atr  # :#this is why we didn't freeze
          @_argument_scanner = Argument_scanner_via_value[ x ]
          @_formal_attribute = atr ; nil
        end

        alias_method :calculate, :instance_exec

        def accept_attribute_value x
          @_parse.session.instance_variable_set @_formal_attribute.as_ivar, x
          NIL_
        end

        def argument_scanner
          @_argument_scanner || @_parse.argument_scanner
        end

        def formal_attribute
          @_formal_attribute
        end

        def index
          @_parse.index
        end

        def session
          @_parse.session
        end
      end

      # ==
    end
  end
end
