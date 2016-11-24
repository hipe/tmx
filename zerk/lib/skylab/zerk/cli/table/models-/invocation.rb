module Skylab::Zerk

  module CLI::Table

    class Models_::Invocation

      # hide "field observers" from the main rendering logic as much as possible

      # -
        def initialize mixed_tuple_st, design

          @design = design

          _my_choices = __page_survey_choices

          @page_scanner = Tabular_::Magnetics::
              PageScanner_via_MixedTupleStream_and_SurveyChoices.call(
            mixed_tuple_st,
            _my_choices,
          )

          if design.has_fields
            num_cols = design.fields.length
            if design.has_at_least_one_field_label
              yes_header_row = true
            end
          end

          @do_display_header_row = yes_header_row
          @notes = Here_::Models_::Notes.new num_cols
        end

        def __page_survey_choices

          fo_def = @design.field_observers
          if fo_def
            @has_field_observers = true
            _fo_a = __field_observers_array_via fo_def
          else
            @has_field_observers = false
          end

          srs_def = @design.summary_rows
          if srs_def
            @__summary_row_definition_collection = srs_def
            _at_end_p = method :__mixed_tuple_stream_for_summary_rows_at_end_of_user_data
          end

          Here_::Models_::FieldSurvey::Choices.new _fo_a, _at_end_p, @design
        end

        def __field_observers_array_via field_observers

          field_observers_controller = field_observers.build_controller

          @field_observers_controller = field_observers_controller

          field_observers_controller.field_observers_array
        end

        def __mixed_tuple_stream_for_summary_rows_at_end_of_user_data _hello_from_tab

          _col = remove_instance_variable :@__summary_row_definition_collection

          _col.build_tuple_stream_for_summary_rows_at_end_of_user_data self
        end

        def read_observer__ sym  # assume
          @field_observers_controller.read_observer sym
        end

        attr_reader(
          :design,
          :do_display_header_row,
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
