module Skylab::Tabular::TestSupport

  module Magnetics_For_Infer_Table

    def self.[] tcc
      tcc.include self
    end

    # -

      def first_table_design_via_ * x_a

        table_design = nil

        inference = build_inference_

        With_first_page_surveyish_via_matrix_and_inference___.call(
          x_a, inference
        ) do |page_surveyISH|

          _ = mags_::TableDesign_via_PageSurvey_and_Inference.call(
            self.is_first_page,
            self.is_last_page,
            page_surveyISH,
            inference,
          )
          table_design = _
          NIL
        end

        table_design
      end

      def build_inference_

        Home_::Operations_::InferTable::Models_Inference___.define do |o|

          o.page_size = self.page_size

          o.target_final_width = self.target_table_width

          o.threshold_for_whether_a_column_is_numeric = 0.618  # explained fully at [#004.B]
        end
      end

      def page_size
        :_page_size_was_not_specified_
      end

      def target_final_width
        :_target_final_width_was_not_specified_
      end

      def mags_
        Home_::Magnetics
      end
    # -

    # ==

    With_first_page_surveyish_via_matrix_and_inference___ = -> x_a, inf, & p do

      # with setup like this, .. eew

      mags_ = Home_::Magnetics

      _mt_st = Stream_[ x_a ]

      user_x = nil

      _cb = -> page_surveyISH do
        user_x = p[ page_surveyISH ]
        NIL
      end

      _cx = mags_::PageScanner_via_MixedTupleStream_and_Inference::
        Build_survey_choices___[ _cb, inf.page_size ]

      _choiceser = -> { _cx }

      scn = mags_::PageScanner_via_MixedTupleStream_and_SurveyChoiceser.call(
        _mt_st, _choiceser )

      scn.gets_one  # NOT USED result is page survey

      user_x
    end

    # ==
  end
end
# #born: early abstracted from first test to use it
