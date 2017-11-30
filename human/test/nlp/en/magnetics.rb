module Skylab::Human::TestSupport

  module NLP::EN::Magnetics

    class << self
      def [] tcm
        tcm.include self ; nil
      end
    end  # >>

    # -

      def e_ expected_string  # "e_" = "want_"

        _exp_fr = __build_the_magnetic_expression_session

        y = _exp_fr.express_into []

        1 == y.length or fail "expression frames produce strings not arrays"

        expect( y.fetch( 0 ) ).to eql expected_string
      end

      def __build_the_magnetic_expression_session

        _ = magnetic_module_
        _.new_session_via_sexp__ @the_iambic_for_the_request_
      end

      def const_for_magnet_for_object_and_subject_
        :Expression_via_Idea_with_Object_and_Subject
      end

      def magnetic_module_for_ const
        NLP_EN_.lib::Magnetics.const_get const, false
      end
    # -
  end
end
