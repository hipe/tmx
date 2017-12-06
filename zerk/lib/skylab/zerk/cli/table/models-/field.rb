module Skylab::Zerk

  module CLI::Table

    class Models_::Field

      def initialize p, x_a
        @sprintf_hash = nil
        _define_or_redefine p, x_a
      end

      def redefine__ p, x_a
        dup._define_or_redefine p, x_a
      end

      def _define_or_redefine p, x_a

        if p
          @_argument_proc = p
        end

        @_scn = Scanner_[ x_a ]
        begin
          send OPTIONS___.fetch @_scn.head_as_is
        end until @_scn.no_unparsed_exists

        if p and instance_variable_defined? :@_argument_proc
          fail __say_not_used p  # #todo
        end

        remove_instance_variable :@_scn
        freeze
      end

      def __say_not_used p
        "proc was passed but was never processed by any parameters (#{ p })"
      end

      def initialize_copy _
        if @sprintf_hash
          self._CODE_SKETCH_cover_this
          @sprintf_hash = @sprintf_hash.dup
        end
      end

      # -- write

      OPTIONS___ = {
        fill_field: :__at_fill_field,
        in_place_of_input_field: :__at_in_place_of_input_field,
        left: :_at_align,
        label: :__at_label,
        parts: :__at_parts,
        right: :_at_align,
        sprintf_format_string_for_nonzero_floats: :__at_sprintf_format_string,
        summary_field: :__at_summary_field,
      }

      def __at_fill_field
        @_scn.advance_one
        _parse_required_field_summary_field_ordinal
        @is_summary_field = true
        @is_summary_field_fill_field = true
        @fill_field_proc = remove_instance_variable( :@_argument_proc )

        # .. probably parse more fill-specific options here ..

        NIL
      end

      def __at_summary_field
        @_scn.advance_one
        _parse_required_field_summary_field_ordinal
        @is_summary_field = true
        @summary_field_proc = remove_instance_variable( :@_argument_proc )
        NIL
      end

      def _parse_required_field_summary_field_ordinal
        send ORDER_OF_OPERATION_SOMEHOW___.fetch @_scn.gets_one
      end

      ORDER_OF_OPERATION_SOMEHOW___ = {
        order_of_operation: :__parse_order_of_operation,
        order_of_operation_next: :__parse_order_of_operation_next,
      }

      def __parse_order_of_operation_next
        @summary_field_ordinal_means = :ordinal_via_next
        NIL
      end

      def __parse_order_of_operation

        d = @_scn.gets_one
        if ! d.respond_to? :integer?  # reminder: this isn't an argument scanner nor an operation
          self._ARGUMENT_ERROR__order_of_operation__argument_must_be_an_integer  # #todo
        end
        @summary_field_ordinal_means = :ordinal_via_literal_integer
        @summary_field_ordinal_value = d
        NIL
      end

      def __at_sprintf_format_string

        _h = ( @sprintf_hash ||= {} )

        _use_key = SPRINTF_LOCAL_KEY_VIA_DSL_KEY___.fetch @_scn.gets_one

        _h[ _use_key ] ||= @_scn.gets_one

        NIL
      end

      def __at_parts
        @_scn.advance_one
        d = @_scn.gets_one
        d.integer? or raise ::TypeError  # #wont-cover
        if ! @is_summary_field_fill_field
          self._COVER_ME__you_cannot_specify_parts_unless_it_is_a_fill_field__  # #todo
        end
        @parts = d
      end

      def __at_label
        @_scn.advance_one
        @label = @_scn.gets_one
      end

      def _at_align
        @align = @_scn.gets_one
      end

      def __at_in_place_of_input_field
        @_scn.advance_one
        @is_in_place_of_input_field =  true
      end

      # -- read

      attr_reader(
        :align,  # :left | :right
        :fill_field_proc,
        :is_in_place_of_input_field,
        :is_summary_field,
        :is_summary_field_fill_field,
        :label,
        :parts,
        :sprintf_hash,
        :summary_field_ordinal_means,
        :summary_field_ordinal_value,
        :summary_field_proc,
      )

      # --

      SPRINTF_LOCAL_KEY_VIA_DSL_KEY___ = {
        sprintf_format_string_for_nonzero_floats: :nonzero_float,
      }
    end
    # ==

    # ==
  end
end
# #tombstone: at full rewrite for [tab], field class, abstruse dep. injection fw
