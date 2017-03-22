module Skylab::Human::TestSupport

  module NLP::EN::Sexp::Magnetics

    class << self
      def [] tcm
        tcm.include self ; nil
      end
    end  # >>

      def e_ expected_string  # "e_" = "expect_"

        _exp_fr = __build_the_magnetic_expression_session

        y = _exp_fr.express_into []

        1 == y.length or fail "expression frames produce strings not arrays"

        y.fetch( 0 ).should eql expected_string
      end

      def __build_the_magnetic_expression_session

        _ = magnetic_module_
        _.new_session_via_sexp__ @the_iambic_for_the_request_
      end

      def magnetic_module_for_ const
        NLP_EN_Sexp_[]::Expression_Sessions.const_get const, false
      end
    # -
  end
end
