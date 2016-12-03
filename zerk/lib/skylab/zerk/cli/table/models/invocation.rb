module Skylab::Zerk

  module CLI::Table

    class Models::Invocation

      # hide "field observers" from the main rendering logic as much as possible

      # -
        def initialize mixed_tuple_st, design

          @design = design

          _my_choices = __init_and_page_survey_choices

          @page_scanner = Tabular_::Magnetics::
              PageScanner_via_MixedTupleStream_and_SurveyChoiceser.call(
            mixed_tuple_st,
            _my_choices,
          )

          if design.has_defined_fields__
            num_cols = design.anticipated_final_number_of_columns_per_defined_fields__
          end

          @notes = Here_::Models_::Notes.new num_cols
        end

        def __init_and_page_survey_choices

          if @design.do_display_header_row
            _etc = method :__init_header_MTs_and_register_header_widths
          end

          _at_page_end = __init_and_any_page_end_hook

          _fo_a = __init_and_any_field_observers_array

          _at_invocation_end = __any_at_invocation_end_hook

          Here_::Models::FieldSurvey::Choices.new(  # 1x
            _fo_a,
            _etc,
            _at_page_end,
            _at_invocation_end,
            @design )
        end

        # ~

        def __init_header_MTs_and_register_header_widths page_surveyish

          # egads :[#050.1]:
          #
          # we need to report header widths post-expansion because that's
          # the position system that headers use (headers can be specified
          # for any kind of field, input-related or derived alike).
          #
          # however, we need to report header widths before we calculate
          # things for fill fields, because fill fields need to know the
          # present projected total table width, and headers can certainly
          # push this width.

          all_defined_fields = @design.all_defined_fields

          tm_a = ::Array.new all_defined_fields.length

          field_survey_writer = page_surveyish.field_survey_writer

          all_defined_fields.each_with_index do |fld, d|

            if fld
              label = fld.label
            end

            _tm = field_survey_writer.see_then_typified_mixed_via_value_and_index(
              label, d )

            # we rely on #table-spot-6 that we don't have to write it to notes..

            tm_a[ d ] = _tm
          end

          @__typified_mixed_tuple_for_header_row = tm_a

          NIL
        end

        def release_typified_mixed_tuple_for_header_row__
          remove_instance_variable :@__typified_mixed_tuple_for_header_row
        end

        # ~

        def __init_and_any_page_end_hook  # BEFORE that other one #here

          index = @design.summary_fields_index__
          if index

            @__summary_fields_index = index

            method :__hack_page_data_for_summary_fields
          else
            @_has_summary_fields = false
            NOTHING_
          end
        end

        def __hack_page_data_for_summary_fields page_data

          @__summary_fields_index.mutate_page_data page_data, self
        end

        # ~

        def __any_at_invocation_end_hook

          srs_def = @design.summary_rows
          if srs_def
            @__summary_row_definition_collection = srs_def
            method :__mixed_tuple_stream_for_summary_rows_at_end_of_user_data
          end
        end

        def __mixed_tuple_stream_for_summary_rows_at_end_of_user_data _hello_from_tab

          _col = remove_instance_variable :@__summary_row_definition_collection

          _col.build_tuple_stream_for_summary_rows_at_end_of_user_data self
        end

        # ~

        def __init_and_any_field_observers_array  # AFTER that other one #here

          fo_def = @design.field_observers
          if fo_def
            @has_field_observers = true
            __field_observers_array_via fo_def
          else
            @has_field_observers = false
            NOTHING_
          end
        end

        def __field_observers_array_via field_observers

          field_observers_controller = field_observers.build_controller

          @field_observers_controller = field_observers_controller

          field_observers_controller.field_observers_array
        end

        # ~

        def read_observer_ sym  # assume
          @field_observers_controller.read_observer sym
        end

        attr_reader(
          :design,
          :field_observers_controller,
          :has_field_observers,
          :notes,
          :page_scanner,
        )
      # -
      # ==
    end
  end
end
# #history: full rewrite during unification (was "row formatter")
