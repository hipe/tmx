module Skylab::Zerk

  module CLI::Table

    module Models_
      Autoloader_[ self ]
    end

    class Models_::Field

      def initialize p, x_a
        @sprintf_formats = nil
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
        # @align  as-is
        # @is_summary_field  as-is
        # @label  as-if (as long as..)
        if @sprintf_formats
          self._CODE_SKETCH_cover_this
          @sprintf_formats = @sprintf_formats.dup
        end
        # @summary_field_ordinal  as-is
      end

      # -- write

      OPTIONS___ = {
        left: :_at_align,
        label: :__at_label,
        right: :_at_align,
        sprintf_format_string_for_nonzero_floats: :_at_sprintf,
        sprintf_format_string_for_nonzero_integers: :_at_sprintf,
        sprintf_format_string_for_zeros: :_at_sprintf,
        summary_field: :__at_summary_field,
      }

      def __at_summary_field
        @_scn.advance_one
        _required_keyword = @_scn.current_token
        if :order_of_operation != _required_keyword
          fail self._COVER_ME_missing_required_keyword  # #todo
        end
        @_scn.advance_one
        d = @_scn.gets_one
        d.respond_to? :integer? or fail
        @summary_field_ordinal = d
        @is_summary_field = true
        @summary_field_proc = remove_instance_variable( :@_argument_proc )
      end

      def __at_label
        @_scn.advance_one
        @label = @_scn.gets_one
      end

      def _at_sprintf
        ( @sprintf_formats ||= {} )[ @_scn.gets_one ] = @_scn.gets_one  # kiss here
        NIL
      end

      def _at_align
        @align = @_scn.gets_one
      end

      # -- read

      attr_reader(
        :align,  # :left | :right
        :is_summary_field,
        :label,
        :sprintf_formats,
        :summary_field_ordinal,
        :summary_field_proc,
      )
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
        :do_display_header_row,
        :the_most_number_of_columns_ever_seen,
      )
    end

    class Models_::Note___

      # preserves across pages.

      def initialize d
        @field_offset = d
        @widest_width_ever = 0
      end

      attr_writer(
        :widest_width_ever,
      )

      attr_reader(
        :field_offset,
        :widest_width_ever,
      )
    end
  end
end
# #tombstone: at full rewrite for [tab], field class, abstruse dep. injection fw
