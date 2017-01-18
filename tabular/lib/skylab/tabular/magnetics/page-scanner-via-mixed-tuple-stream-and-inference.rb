module Skylab::Tabular

  class Magnetics::PageScanner_via_MixedTupleStream_and_Inference <  # 1x
      Common_::Dyadic

    # (for now, this is the node that emits the thing about no lines
    #  in upstream. but we might move it to somewhere else.)

    # -
      def initialize mt_st, inf, & p
        @_listener = p

        @inference = inf
        @mixed_tuple_upstream = mt_st
      end

      def execute
        self
      end

      def flush_to_line_stream
        @_gets_line = :__gets_first_line
        Common_.stream do
          send @_gets_line
        end
      end

      def __gets_first_line

        _mt = remove_instance_variable :@mixed_tuple_upstream
        scn = Orthrus___.new _mt, @inference
        if scn.no_unparsed_exists
          __when_no_items
        else
          __gets_first_line_normally scn
        end
      end

      def __when_no_items
        _close
        @_listener.call :info, :expression, :no_lines_in_input do |y|
          y << "(no lines in input. done.)"
        end
        NIL
      end

      def __gets_first_line_normally scn

        @__notes = Zerk_::CLI::Table::Models::Notes.new
        @_gets_line = :__gets_line_normally
        @_orthrus = scn

        _first_line_of_next_page
      end

      def _first_line_of_next_page

        _dyad = @_orthrus.gets_one
        @_current_line_stream = _dyad.__flush_to_line_stream_ @__notes
        send @_gets_line
      end

      def __gets_line_normally
        line = @_current_line_stream.gets
        if line
          line
        elsif @_orthrus.no_unparsed_exists
          remove_instance_variable :@_current_line_stream
          remove_instance_variable :@__notes
          remove_instance_variable :@_orthrus
          _close
          NOTHING_
        else
          _first_line_of_next_page
        end
      end

      def _close
        remove_instance_variable :@_gets_line
        freeze ; nil
      end

    # -
    # ==

    class Orthrus___

      # ("orthrus" is a two-headed dog of greek mythology. the items this
      #  scanner produces are two-headed (we now call them "dyads"). this
      #  horrible name is being preserved for now b.c of how local this is.)

      def initialize mt_st, inf

        @__inference = inf

        choices = Build_survey_choices___.call(
          method( :__table_design_via_page_survey ),
          inf.page_size,
        )
        _choiceser = -> { choices }
          scn =
        Magnetics::PageScanner_via_MixedTupleStream_and_SurveyChoiceser.call(
          mt_st,
          _choiceser,
        )
        if scn.no_unparsed_exists
          @no_unparsed_exists = true
        else
          @_remote_scanner = scn
          @_post_gets_one = :__post_gets_one_normally
          send @_post_gets_one
        end
      end

      def __post_gets_one_normally

        _page_survey = @_remote_scanner.gets_one
        _design = remove_instance_variable :@__DESIGN

        @__current_dyad = Dyad___.new _design, _page_survey

        if @_remote_scanner.no_unparsed_exists
          @_post_gets_one = :__close
        end
        NIL
      end

      def gets_one
        x = remove_instance_variable :@__current_dyad
        send @_post_gets_one
        x
      end

      def __close
        @no_unparsed_exists = true
        remove_instance_variable :@__inference
        remove_instance_variable :@_remote_scanner
        remove_instance_variable :@_post_gets_one
        NIL
      end  # 1x

      def __table_design_via_page_survey page_surveyish

        @__DESIGN = Magnetics::TableDesign_via_PageSurvey_and_Inference.call(  # 1x
          @_remote_scanner.was_first_page,
          @_remote_scanner.no_unparsed_exists,
          page_surveyish,
          @__inference,
        )
        NIL
      end

      attr_reader(
        :no_unparsed_exists,
      )
    end

    # ==

    class Dyad___

      def initialize _1, _2
        @design = _1
        @page_survey = _2
      end

      def __flush_to_line_stream_ notes

        _invo = Zerk_::CLI::Table::Models::Invocation.define do |o|
          o.notes = notes
          o.design = @design
          o.the_only_page_survey = @page_survey
        end

        _line_st = _invo.flush_to_line_stream
        _line_st  # #todo
      end
    end

    # ==

    Build_survey_choices___ = -> designer, page_size do

      _field_surveyor = Magnetics::FieldSurveyor_via_Inference[]

      Home_::Models::PageSurveyChoices.define do |o|

        o.hook_for_end_of_page = -> page_surveyish do
          designer[ page_surveyish ]
          NIL
        end

        o.hook_for_end_of_mixed_tuple_stream = -> _nothing_from_tab do
          # hi. for #wish [#006] summary row
          NOTHING_
        end

        o.field_surveyor = _field_surveyor

        o.page_size = page_size
      end
    end

    # ==

    Magnetics::FieldSurveyor_via_Inference = Lazy_.call do  # #stowaway

      # when we're doing inference, we have a custom field survey class for that

      Home_::Models_::FieldSurveyor.define do |o|

        o.hook_mesh = Magnetics::PageSurvey_via_MixedTupleStream::HOOK_MESH

        o.field_survey_class = Models::FieldSurvey_for_Inference  # 1x
      end
    end

    # ==
  end
end
# #history: born for infer table
