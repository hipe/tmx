require_relative '../test-support'

module Skylab::Tabular::TestSupport

  describe "[tab] magnetics - field surveyor via inference" do

    TS_[ self ]
    use :memoizer_methods

    context "2 pages, each 2 items long" do

      shared_subject :_pages do

        _pages_via_matrix(
          [ "jim-flim-mcgee-12", 32 ],
          [ "jam-flam-magoozle-1", 16 ],
          [ -7, "woof" ],
          [ -3, "barko" ],
        )
      end

      def _page_size
        2
      end

      it "two pages" do
        _pages.length == 2 || fail
      end

      it "first page, min & max are right, on the one column and not the other" do
        _page = _pages.fetch 0
        _min_and_max_of_column_of_page( 16, 32, 1, _page )
      end

      it "second page, min & max are right, on the other column and not the one" do
        _page = _pages.fetch 1
        _min_and_max_of_column_of_page( -7, -3, 0, _page )
      end
    end

    def _min_and_max_of_column_of_page min, max, col, page

      case col
      when 0
        other_col = 1
      when 1
        other_col = 0
      else
        TS_._BREAK_THIS_TEST_OUT_into_its_own_method
      end

      a = page.every_survey_of_every_field

      field = a.fetch col
      other_field = a.fetch other_col

      field.number_of_numerics.nonzero? || fail
      other_field.number_of_numerics.zero? || fail

      field_survey = a.fetch col
      field_survey.minmax_min == min || fail
      field_survey.minmax_max == max || fail
    end

    def _pages_via_matrix * matr

      mags = Home_::Magnetics

      _mixed_tuple_stream = Stream_[ matr ]

      _field_surveyor = mags::FieldSurveyor_via_Inference[]

      survey_choices = Home_::Models::PageSurveyChoices.define do |o|

        o.field_surveyor = _field_surveyor

        o.page_size = self._page_size
      end

      _always_same = -> { survey_choices }

      scn = mags::PageScanner_via_MixedTupleStream_and_SurveyChoiceser.call(
        _mixed_tuple_stream,
        _always_same,
      )

      pages = []
      until scn.no_unparsed_exists
        pages.push scn.gets_one
      end
      pages
    end
  end
end
# #born during and for "infer table"
