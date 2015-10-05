module Skylab::Human

  # (we want to be able to see const defined here..)

  module TestSupport

    # (..and here)

    module Nlp::En::Expression_Frame_Support

      class << self
        def [] tcm
          tcm.include Instance_Methods___
          NIL_
        end
      end  # >>

      module Instance_Methods___

        def e_ expected_string  # "e_" = "expect_"

          _exp_fr = __build_the_expression_frame

          y = _exp_fr.express_into []

          1 == y.length or fail "expression frames produce strings not arrays"

          y.fetch( 0 ).should eql expected_string
        end

        def __build_the_expression_frame

          _expr_fr_mod = frame_module_

          _expr_fr_mod.new_via_iambic @the_iambic_for_the_request_
        end
      end
    end
  end
end
