require_relative '../../../../test-support'

module Skylab::Human::TestSupport

  describe "[hu] [..] expression sessions - list through columnar aggregatoin of statementishes" do

    extend TS_

    it "(cute)" do

      o = Home_::NLP::EN::Sexp.expression_session_for(
        :list, :through, :columnar_aggregation_of_statementishes,
      )

      o.add :drink, :tea
      o.add :eat, :tofu
      o.add :drink, :lemonade

      _ = o.express_into_line_context []
      _.should eql [ "drinking teas and lemonades and eatting tofus" ]
    end
  end
end
