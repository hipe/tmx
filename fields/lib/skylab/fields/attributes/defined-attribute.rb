module Skylab::Fields

  class Attributes

    class DefinedAttribute < SimplifiedName

      def initialize k, & edit_p

        @argument_arity = :one

        @_become_optional_m = :_change_parameter_arity_to_be_optional_once
        @_pending_meths_definers = nil

        @_RW_m = :__receive_first_read_and_write_proc
        @_RW_p_kn = nil
        @_read_m = :__receive_first_read_proc
        @_read_p_kn = nil
        @_write_m = :__receive_first_write_proc
        @_write_p_kn = nil

        super k do |me|
          edit_p[ me ]
        end
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

      def read_and_write_by & p
        send @_RW_m, p
      end

      def read_by & p
        send @_read_m, p
      end

      def write_by & p
        send @_write_m, p
      end

      def __receive_first_read_and_write_proc p
        @_read_m = :_locked
        @_RW_m = :_locked
        @_write_m = :_locked
        @_RW_p_kn = Callback_::Known_Known[ p ] ; nil
      end

      def __receive_first_read_proc p
        @_read_m = :_locked
        @_RW_m = :_locked
        @_read_p_kn = Callback_::Known_Known[ p ] ; nil
      end

      def __receive_first_write_proc p
        @_write_m = :_locked
        @_RW_m = :_locked
        @_write_p_kn = Callback_::Known_Known[ p ] ; nil
      end

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

        r_kn = remove_instance_variable :@_read_p_kn
        rw_kn = remove_instance_variable :@_RW_p_kn
        w_kn = remove_instance_variable :@_write_p_kn

        if rw_kn
          # then our state machine "ensures" that the others were not
          @__rw = rw_kn.value_x
          @_interpret_m = :__custom_interpret
        else
          @_read = r_kn ? r_kn.value_x : Read___
          @_write = w_kn ? w_kn.value_x : Write___
          @_interpret_m = :__common_interpret
        end

        super
      end

      # --

      def write sess, st  # #EXPERIMENTAL #cover-me #todo

        pa = Here_::Lib::Parse_and_or_Normalize.new sess
        pa.argument_stream = st
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

      Read___ = -> do
        argument_stream.gets_one
      end

      Write___ = -> x, _ do
        accept_attribute_value x
        KEEP_PARSING_
      end

      # ==

      class Interpretation_Services___

        def initialize attr, parse
          @_arg_st = nil
          @_formal_attribute = attr
          @_parse = parse
          # for now, don't freeze only because #this
        end

        def _mutate_for_redirect x, atr  # :#this is why we didn't freeze
          @_arg_st = Argument_stream_via_value[ x ]
          @_formal_attribute = atr ; nil
        end

        alias_method :calculate, :instance_exec

        def accept_attribute_value x
          @_parse.session.instance_variable_set @_formal_attribute.as_ivar, x
          NIL_
        end

        def argument_stream
          @_arg_st || @_parse.argument_stream
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
