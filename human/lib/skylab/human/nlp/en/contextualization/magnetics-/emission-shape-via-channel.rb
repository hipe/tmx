module Skylab::Human

  class NLP::EN::Contextualization

    module Magnetics_::Contextualized_Expression_via_Emission ; class << self

      # (this is near a solution for #[#co-046] emission handling pattern)
      # (side-effect is to resolve a trilean (shh))

      def via_magnetic_parameter_store ps

        if ps.emission_is_expression__
          Magnetics_::Contextualized_Expression_via_Emission_that_Is_Expression[ ps ]
        else
          Magnetics_::Contextualized_Expression_via_Emission_that_Is_Event[ ps ]
        end
      end

      alias_method :[], :via_magnetic_parameter_store
    end ; end
  end
end
# #history: broke out of "expression via emission"
