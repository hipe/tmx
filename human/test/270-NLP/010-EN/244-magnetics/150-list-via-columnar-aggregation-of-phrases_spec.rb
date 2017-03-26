require_relative '../../../test-support'

module Skylab::Human::TestSupport

  describe "[hu] NLP EN mags - list via columnar aggregation of phrases" do

    TS_[ self ]

    it "(cute)" do  # #cov1.4

      o = NLP_EN_.sexp_lib.expression_session_for(
        :list, :via, :columnar_aggregation_of_phrases,
      )

      o.add :drink, :tea
      o.add :eat, :tofu
      o.add :drink, :lemonade

      _ = o.express_into_line_context []
      _.should eql [ "drinking teas and lemonades and eatting tofus" ]
    end
  end
end
