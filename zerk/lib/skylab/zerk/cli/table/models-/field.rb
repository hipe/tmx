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

        @_scn = Common_::Polymorphic_Stream.via_array x_a
        begin
          send OPTIONS___.fetch @_scn.current_token
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
        _required_keyword = @_scn.current_token
        if :order_of_operation != _required_keyword
          self._COVER_ME_missing_required_keyword__order_of_operation__  # #todo
        end
        @_scn.advance_one
        d = @_scn.gets_one
        if ! d.respond_to? :integer?
          self._COVER_ME__order_of_operation__argument_must_be_an_integer  # #todo
        end
        @summary_field_ordinal = d
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
        :summary_field_ordinal,
        :summary_field_proc,
      )

      # --

      SPRINTF_LOCAL_KEY_VIA_DSL_KEY___ = {
        sprintf_format_string_for_nonzero_floats: :nonzero_float,
      }
    end

    # ==

    class Models_::Notes  # 1x

      # mutable guy for aggregating statistical information about the table

      def initialize d
        @_a = []
        @the_most_number_of_columns_ever_seen = d || 0
      end

      def see_this_number_of_columns d
        if @the_most_number_of_columns_ever_seen < d
          @the_most_number_of_columns_ever_seen = d
        end
      end

      def for_field d
        @_a[ d ] ||= Models_::Note___.new d
      end

      attr_reader(
        :the_most_number_of_columns_ever_seen,
      )
    end

    class Models_::Note___

      # preserves across pages.

      def initialize d
        @defined_field_offset = d
        @widest_width_ever = 0
      end

      attr_writer(
        :widest_width_ever,
      )

      attr_reader(
        :defined_field_offset,
        :widest_width_ever,
      )
    end

    # ==

    # ==
  end
end
# #tombstone: at full rewrite for [tab], field class, abstruse dep. injection fw
